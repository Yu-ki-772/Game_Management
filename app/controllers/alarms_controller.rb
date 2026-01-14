class AlarmsController < ApplicationController
  #=================================================
  # フィルタ設定
  #=================================================
  # indexとpendingのみログイン前でも許可
  skip_before_action :authenticate_user!, only: [ :index, :pending ]

  # 対象アラームをセット
  before_action :set_alarm, only: [ :edit, :update, :unlock, :destroy ]

  #=================================================
  # 一覧・表示系アクション
  #=================================================
  def index
    if user_signed_in?
      # ログインしている場合の処理
      # 未送信でかつ未来のものに絞る
      @alarms = current_user.alarms.unsent.future.locked.order(scheduled_at: :asc)
    end
  end

  def pending
    if user_signed_in?
      # ログインしている場合の処理
      # まだ解除していないくて、かつ設定時間が２４時間前後のものに絞る
      @alarms = current_user.alarms.locked.near.order(scheduled_at: :asc)
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

  # アラームの解除の処理
  def unlock
    success, @alarm_log = @alarm.unlock_with_log

    if success
      redirect_to alarm_logs_path, notice: "アラームを解除しました", status: :see_other
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

  # 現在のユーザのアラームから対象を取得
  def set_alarm
    @alarm = current_user.alarms.find(params[:id])
  end

  # 許可するパラメータの定義
  def alarm_params
    params.require(:alarm).permit(:label, :scheduled_at)
  end

  # アラーム解除失敗時の処理
  # pendingページを再表示し、エラーメッセージを表示
  def handle_unlock_failure
    @alarms = current_user.alarms.locked.near.order(scheduled_at: :asc)
    flash.now[:alert] = "アラームを解除できませんでした"
    render "alarms/pending", status: :unprocessable_entity
  end
end
