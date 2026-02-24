class AlarmReminderJob < ApplicationJob
  queue_as :default

  retry_on Net::OpenTimeout, Net::ReadTimeout, wait: 5.seconds, attempts: 5

  def perform(alarm_uuid)
    alarm = Alarm.find_by(uuid: alarm_uuid)
    return unless alarm

    # 全メンバー（作成者含む）のうち、まだアンロックしていない人を絞り込む
    unlocked_user_uuids = alarm.alarm_logs.pluck(:user_uuid)

    unnotified_memberships = alarm.alarm_memberships
                                  .where.not(user_uuid: unlocked_user_uuids)
                                  .includes(:user)

    return if unnotified_memberships.empty?

    minutes_until_alarm = ((alarm.scheduled_at - Time.current) / 60).round

    unnotified_memberships.each do |membership|
      if membership.user_uuid == alarm.user_uuid
        # 作成者向けのリマインダー
        AlarmMailer.alarm_reminder(alarm_uuid, minutes_until_alarm).deliver_now
      else
        # 招待メンバー向けのリマインダー
        AlarmMailer.member_alarm_reminder(alarm_uuid, membership.user_uuid, minutes_until_alarm).deliver_now
      end
    end
  end
end
