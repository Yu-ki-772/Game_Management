class AlarmLogsController < ApplicationController
  def index
    base = AlarmLog.where(user_uuid: current_user.uuid)

    @pagy, @alarm_logs = pagy(
      base.includes(alarm: :creator).order(unlocked_at: :desc),
      limit: 20
    )

    all_minutes_to_unlock      = base.order(:unlocked_at).pluck(:minutes_to_unlock)
    @total_count     = all_minutes_to_unlock.size
    @average_minutes = all_minutes_to_unlock.any? ? (all_minutes_to_unlock.sum.to_f / all_minutes_to_unlock.size).round : nil

    # 直近7回
    recent_minutes_to_unlock = all_minutes_to_unlock.last(7)
    @minutes_stats = recent_minutes_to_unlock.each_with_index.to_h do |min, i|
      [ "#{i + 1}回目", min ]
    end

    # フレンドごとの比較
    @friend_stats = base
      .joins(alarm: { alarm_memberships: :user })
      .where.not(alarm_memberships: { user_uuid: current_user.uuid })
      .group("users.name")
      .average("alarm_logs.minutes_to_unlock")
      .transform_values(&:round)
      .sort_by { |_, value| value }.reverse
      .to_h

    # プレイ時間の日別合計（過去7日間）
    @play_duration_stats = base
      .where.not(play_duration: nil)
      .group_by_day(:unlocked_at, time_zone: "Tokyo", format: "%-m月%-d日", last: 7)
      .sum(:play_duration)
  end

  def show
    @alarm_log = AlarmLog
      .where(user_uuid: current_user.uuid)
      .includes(alarm: [ :creator, { alarm_memberships: :user } ])
      .find(params[:id])

    @members = @alarm_log.alarm.alarm_memberships
      .map(&:user)
      .reject { |user| user.uuid == current_user.uuid }

    @other_member_logs = AlarmLog
      .where(alarm_uuid: @alarm_log.alarm_uuid)
      .where.not(user_uuid: current_user.uuid)
      .includes(:user)
  end
end
