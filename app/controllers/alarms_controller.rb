class AlarmsController < ApplicationController
  # indexのみログイン前でも許可
  skip_before_action :authenticate_user!, only: [ :index ]
  def index
    if user_signed_in?
      # ログインしている場合の処理
      @alarms = current_user.alarms.order(scheduled_at: :asc)
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
      flash.now[:danger] = "アラームを作成できませんでした"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def alarm_params
    params.require(:alarm).permit(:label, :scheduled_at)
  end
end
