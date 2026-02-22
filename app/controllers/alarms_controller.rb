class AlarmsController < ApplicationController
  #=================================================
  # フィルタ設定
  #=================================================
  skip_before_action :authenticate_user!, only: [ :index, :pending, :calendar ]
  before_action :set_alarm, only: [ :edit, :update, :unlock, :destroy ]

  #=================================================
  # 一覧・表示系アクション
  #=================================================
  def index
    if user_signed_in?
      @alarms = current_user.alarms.unsent.future.locked
                            .includes(
                              creator: { avatar_attachment: :blob },
                              members: { avatar_attachment: :blob }
                            )
                            .order(scheduled_at: :asc)


      @invited_alarms = current_user.invited_alarms
                                    .unsent
                                    .future
                                    .locked
                                    .not_unlocked_by(current_user)
                                    .includes(
                                      creator: { avatar_attachment: :blob },
                                      members: { avatar_attachment: :blob }
                                    )
                                    .order(scheduled_at: :asc)
    end
  end

  # カレンダー
  def calendar
    return redirect_to new_user_session_path unless user_signed_in?

    # 現在の日付から表示する月を取得（デフォルトは今月）
    @start_date = Date.today

    # カレンダー表示用の期間を計算（カレンダーグリッド全体）
    start_of_calendar = @start_date.beginning_of_month.beginning_of_week(:sunday)
    end_of_calendar = @start_date.end_of_month.end_of_week(:sunday)

    # 自分が作成したアラーム
    @my_alarms = current_user.alarms
                            .locked
                            .in_period(start_of_calendar, end_of_calendar)
                            .includes(
                              :alarm_memberships
                            )
                            .order(Arel.sql("COALESCE(started_at, scheduled_at) ASC"))

    # 招待されたアラーム
    @invited_alarms = current_user.invited_alarms
                                  .locked
                                  .in_period(start_of_calendar, end_of_calendar)
                                  .includes(
                                    :alarm_memberships
                                  )
                                  .order(Arel.sql("COALESCE(started_at, scheduled_at) ASC"))

    # 全アラームを結合してstart_timeでソート
    @alarms = (@my_alarms + @invited_alarms).sort_by(&:start_time)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def pending
    if user_signed_in?
      @alarms = current_user.alarms.locked.near.includes(:alarm_memberships).order(scheduled_at: :asc)

      @invited_alarm_memberships = pending_invited_alarm_memberships
    end
  end

  #=================================================
  # 作成・更新系アクション
  #=================================================
  def new
    @alarm = current_user.alarms.build

    now = Time.current.change(sec: 0)

    # デフォルトは1時間後
    @alarm.scheduled_at = now + 1.hour

    # カレンダーから未来の日付が渡された場合は上書き
    if params[:date].present?
      selected_date = Date.parse(params[:date]) rescue nil

      if selected_date && selected_date > Date.today
        @alarm.scheduled_at = selected_date.to_time.change(hour: now.hour, min: now.min)
      end
    end

    # 作成画面に入ったときに、started_atがscheduled_atの1時間前にする
    @alarm.started_at = @alarm.scheduled_at - 1.hour
  end

  def create
    @alarm = current_user.alarms.new(alarm_params)

    if @alarm.save
      redirect_to alarms_path, notice: "アラームを作成しました", status: :see_other
    else
      flash.now[:alert] = "アラームを作成できませんでした"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @alarm.update(alarm_params)
      redirect_to alarms_path, notice: "アラームを更新しました", status: :see_other
    else
      flash.now[:alert] = "アラームを更新できませんでした"
      render :edit, status: :unprocessable_entity
    end
  end

  # アラームのストップの処理
  def unlock
    success, @alarm_log = @alarm.unlock_with_log

    if success
      # モーダル表示用に@alarm_logのidを渡す。
      flash[:alarm_log_id] = @alarm_log.id
      redirect_to alarm_logs_path, status: :see_other
    else
      handle_unlock_failure
    end
  end

  #=================================================
  # 削除アクション
  #=================================================
  def destroy
    @alarm.destroy!
    redirect_to alarms_path, notice: "アラームを削除しました", status: :see_other
  end

  private

  #=================================================
  # privateメソッド
  #=================================================

  def set_alarm
    @alarm = current_user.alarms.find(params[:id])
  end

  def alarm_params
    params.require(:alarm).permit(:label, :scheduled_at, :started_at)
  end

  # pendingとhandle_unlock_failureの両方で同じ招待アラームの取得処理が必要なため、
  # メソッドとして切り出すことで重複を避ける。
  # { alarm_uuid => membership } というHashを返すことで、
  # ビュー側がalarm.uuidをキーにO(1)でmembershipを取得できる。
  def pending_invited_alarm_memberships
    current_user.alarm_memberships
                .not_unlocked_by(current_user)
                .joins(:alarm)
                .merge(Alarm.locked.near)
                .eager_load(alarm: [ :alarm_memberships, { creator: { avatar_attachment: :blob } } ])
                .order("alarms.scheduled_at ASC")
                .index_by(&:alarm_uuid)
  end

  def handle_unlock_failure
    @alarms = current_user.alarms.locked.near
                          .includes(
                            :alarm_memberships,
                            creator: { avatar_attachment: :blob },
                            members: { avatar_attachment: :blob }
                          ).
                          order(scheduled_at: :asc)

    @invited_alarm_memberships = pending_invited_alarm_memberships

    flash.now[:alert] = "アラームをストップできませんでした"
    render "alarms/pending", status: :unprocessable_entity
  end
end
