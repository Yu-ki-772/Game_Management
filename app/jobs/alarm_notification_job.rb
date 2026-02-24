class AlarmNotificationJob < ApplicationJob
  queue_as :default

  retry_on Net::OpenTimeout, Net::ReadTimeout, wait: 5.seconds, attempts: 5

  def perform(alarm_uuid)
    alarm = Alarm.find_by(uuid: alarm_uuid)
    return unless alarm

    unlocked_user_uuids = alarm.alarm_logs.pluck(:user_uuid)

    unnotified_memberships = alarm.alarm_memberships
                                  .where.not(user_uuid: unlocked_user_uuids)

    return if unnotified_memberships.empty?

    unnotified_memberships.each do |membership|
      AlarmMemberNotificationJob.perform_later(
        alarm_uuid,
        membership.user_uuid,
        membership.user_uuid == alarm.user_uuid
      )
    end

    alarm.update_column(:sent, true)
  end
end
