class AlarmLogsController < ApplicationController
  # ログイン前でも許可
  skip_before_action :authenticate_user!

  def index
    if user_signed_in?
      # ログインしている場合の処理
      @alarm_logs = AlarmLog.where(user_uuid: current_user.uuid)
                            .includes(alarm: :creator)
                            .order(unlocked_at: :desc)
    end
  end
end
