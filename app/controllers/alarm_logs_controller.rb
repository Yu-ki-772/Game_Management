class AlarmLogsController < ApplicationController
  # ログイン前でも許可
  skip_before_action :authenticate_user!

  def index
    if user_signed_in?
      # ログインしている場合の処理
      @alarm_logs = current_user.alarm_logs.includes(:alarm).order(unlocked_at: :desc)
    end
  end
end
