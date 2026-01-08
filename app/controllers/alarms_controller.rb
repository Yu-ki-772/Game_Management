class AlarmsController < ApplicationController
  # indexのみログイン前でも許可
  skip_before_action :authenticate_user!, only: [ :index ]
  def index
    if user_signed_in?
      # ログインしている場合の処理
      # 未送信でかつ未来のものに絞る
      @alarms = current_user.alarms.unsent.future.order(scheduled_at: :asc)
    end
  end

  def new
    @alarm = Alarm.new
  end

  def create
    @alarm = current_user.alarms.new(alarm_params)

    if @alarm.save
      redirect_to alarms_path, notice: "アラームを作成しました"
    else
      flash.now[:alert] = "アラームを作成できませんでした"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @alarm = current_user.alarms.find(params[:id])
  end

  def update
    @alarm = current_user.alarms.find(params[:id])

    if @alarm.update(alarm_params)
      redirect_to alarms_path, notice: "アラームを更新しました"
    else
      flash.now[:alert] = "アラームを更新できませんでした"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @alarm = current_user.alarms.find(params[:id])
    @alarm.destroy!
    redirect_to alarms_path, notice: "アラームを削除しました", status: :see_other
  end

  private

  def alarm_params
    params.require(:alarm).permit(:label, :scheduled_at)
  end
end
