class AlarmMembership < ApplicationRecord
  belongs_to :user, foreign_key: "user_uuid",  primary_key: "uuid"
  belongs_to :alarm, foreign_key: "alarm_uuid", primary_key: "uuid"

  # 指定したユーザーがまだストップしていないメンバーシップだけを返す。
  scope :not_unlocked_by, ->(user) {
    where.not(
      alarm_uuid: AlarmLog.where(user_uuid: user.uuid).select(:alarm_uuid)
    )
  }

  # アラームをストップ済みかどうかを判定する。
  def unlocked?
    alarm.alarm_logs.exists?(user_uuid: user_uuid)
  end
  
  def unlock
    return false if unlocked?

    current_time = Time.current
    times_defer = current_time - alarm.scheduled_at

    alarm.alarm_logs.create!(
      unlocked_at: current_time,
      minutes_to_unlock: (times_defer / 60).round,
      user_uuid: user_uuid
    )

    alarm_log
  rescue ActiveRecord::RecordInvalid
    nil
  end
end
