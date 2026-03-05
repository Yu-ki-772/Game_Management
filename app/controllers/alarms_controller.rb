class AlarmsController < ApplicationController
  #=================================================
  # フィルタ設定
  #=================================================
  before_action :set_alarm, only: [ :edit, :update, :unlock, :destroy ]

  #=================================================
  # 一覧・表示系アクション
  #=================================================
  def index
    @memberships = current_user.alarm_memberships
                              .joins(:alarm)
                              .merge(Alarm.unsent.future.locked)
                              .includes(
                                alarm: [
                                  { creator: { avatar_attachment: :blob } },
                                  { members: { avatar_attachment: :blob } },
                                  :alarm_memberships
                                ]
                              )
                              .order("alarms.scheduled_at asc")
  end

  # カレンダー
  def calendar
    # 現在の日付から表示する月を取得（デフォルトは今月）
    @start_date = Date.today

    # カレンダー表示用の期間を計算（カレンダーグリッド全体）
    start_of_calendar = @start_date.beginning_of_month.beginning_of_week(:sunday)
    end_of_calendar = @start_date.end_of_month.end_of_week(:sunday)

    memberships = current_user.alarm_memberships
                              .joins(:alarm)
                              .merge(
                                Alarm.locked.in_period(start_of_calendar, end_of_calendar)
                              )
                              .includes(
                                alarm: :alarm_memberships
                              )

    @alarms = memberships.map(&:alarm)
                        .uniq(&:uuid)
                        .sort_by(&:start_time)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def pending
    @alarm_memberships = pending_alarm_memberships
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
      check_pwa_install_prompt
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
    membership = @alarm.alarm_memberships.find_by(user_uuid: current_user.uuid)

    # メンバーシップが存在しない場合
    if membership.nil?
      flash.now[:alert] = "アラームをストップできませんでした"
      render "alarms/pending", status: :unprocessable_entity
      return
    end

    alarm_log = membership.unlock

    if alarm_log
      flash[:alarm_log_id] = alarm_log.id
      redirect_to alarm_logs_path, notice: "アラームをストップしました", status: :see_other
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
    params.require(:alarm).permit(:label, :scheduled_at, :started_at, :reminder_minutes)
  end

  # pendingとhandle_unlock_failureの両方で同じ招待アラームの取得処理が必要なため、
  # メソッドとして切り出すことで重複を避ける。
  # { alarm_uuid => membership } というHashを返すことで、
  # ビュー側がalarm.uuidをキーにO(1)でmembershipを取得できる。
  def pending_alarm_memberships
    current_user.alarm_memberships
                .not_unlocked_by(current_user)
                .joins(:alarm)
                .merge(Alarm.locked.stoppable_now)
                .includes(
                  :user,
                  alarm: [ :alarm_memberships, { members: :avatar_attachment }, { creator: :avatar_attachment } ]
                )
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

    @alarm_memberships = pending_alarm_memberships

    flash.now[:alert] = "アラームをストップできませんでした"
    render "alarms/pending", status: :unprocessable_entity
  end

  # インストール（ホーム画面に追加）用のプロンプトの表示
  def check_pwa_install_prompt
    return if current_user.pwa_install_prompted

    flash[:show_pwa_install_prompt] = true
    current_user.update!(pwa_install_prompted: true)
  end
end
