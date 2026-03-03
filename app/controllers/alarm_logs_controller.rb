class AlarmLogsController < ApplicationController

  def index
    @alarm_logs = AlarmLog.where(user_uuid: current_user.uuid)
                          .includes(alarm: :creator)
                          .order(unlocked_at: :desc)
  end
end
