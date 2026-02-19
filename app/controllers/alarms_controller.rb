class AlarmsController < ApplicationController
  #=================================================
  # フィルタ設定
  #=================================================
  skip_before_action :authenticate_user!, only: [ :index, :pending ]
  before_action :set_alarm, only: [ :edit, :update, :unlock, :destroy ]

  #=================================================
  # 一覧・表示系アクション
  #=================================================
  def index
    if user_signed_in?
      @alarms = current_user.alarms.unsent.future.locked
                            .includes(
                              :alarm_memberships,
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
                                      :alarm_memberships,
                                      creator: { avatar_attachment: :blob },
                                      members: { avatar_attachment: :blob }
                                    )
                                    .order(scheduled_at: :asc)
    end
  end

  def pending
    if user_signed_in?
      # pending画面はアバターもメンバーも表示しないため、includesは不要
      @alarms = current_user.alarms.locked.near.order(scheduled_at: :asc)
      
      @invited_alarm_memberships = pending_invited_alarm_memberships
    end
  end

  #=================================================
  # 作成・更新系アクション
  #=================================================
  def new
    @alarm = Alarm.new
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
    params.require(:alarm).permit(:label, :scheduled_at)
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
                .eager_load(alarm: { creator: { avatar_attachment: :blob } })
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