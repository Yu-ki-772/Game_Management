class HomeController < ApplicationController
  # ログイン前でも許可
  skip_before_action :authenticate_user!

  def top
    if user_signed_in?
      load_calendar_data
      # @start_date と @alarms がセットされる
    end
  end

  private

  def load_calendar_data
    @start_date = params[:start_date].present? ? params[:start_date].to_date : Date.today

    start_of_calendar = @start_date.beginning_of_month.beginning_of_week(:sunday)
    end_of_calendar   = @start_date.end_of_month.end_of_week(:sunday)

    memberships = current_user.alarm_memberships
                              .joins(:alarm)
                              .merge(
                                Alarm.locked.in_period(start_of_calendar, end_of_calendar)
                              )
                              .includes(alarm: :alarm_memberships)

    @alarms = memberships.map(&:alarm)
                        .uniq(&:uuid)
                        .sort_by(&:start_time)
  end
end
