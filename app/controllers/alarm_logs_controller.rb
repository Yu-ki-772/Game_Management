class AlarmLogsController < ApplicationController
  def index
    base = AlarmLog.where(user_uuid: current_user.uuid)

    all_minutes_to_stop = base.order(:stopped_at).pluck(:minutes_to_stop)
    @average_minutes = all_minutes_to_stop.any? ? (all_minutes_to_stop.sum.to_f / all_minutes_to_stop.size).round : nil

    recent_minutes_to_stop = all_minutes_to_stop.last(7)
    @minutes_stats = recent_minutes_to_stop.each_with_index.to_h do |min, i|
      [ "#{i + 1}回目", min ]
    end

    @friend_stats = base
      .joins(alarm: { alarm_memberships: :user })
      .where.not(alarm_memberships: { user_uuid: current_user.uuid })
      .group("users.name")
      .average("alarm_logs.minutes_to_stop")
      .transform_values(&:round)
      .sort_by { |_, value| value }.reverse
      .to_h

    @play_duration_stats = base
      .where.not(play_duration: nil)
      .group_by_day(:stopped_at, time_zone: "Tokyo", format: "%-m月%-d日", last: 7)
      .sum(:play_duration)
  end

  def list
    base = AlarmLog.where(user_uuid: current_user.uuid)

    @pagy, @alarm_logs = pagy(
      base.order(stopped_at: :desc),
      limit: 20
    )
    @total_count = base.count
  end
end
