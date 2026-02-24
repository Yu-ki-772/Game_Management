class AlarmMemberNotificationJob < ApplicationJob
  queue_as :default

  retry_on Net::OpenTimeout, Net::ReadTimeout, wait: 5.seconds, attempts: 5
  # resendの、「１秒に２つのリクエストまで」という制約に反した場合のエラーハンドリング
  retry_on Resend::Error::RateLimitExceededError, wait: 5.seconds, attempts: 3

  def perform(alarm_uuid, user_uuid, is_creator)
    alarm = Alarm.find_by(uuid: alarm_uuid)
    return unless alarm

    return if alarm.alarm_logs.exists?(user_uuid: user_uuid)

    if is_creator
      AlarmMailer.alarm_notification(alarm_uuid).deliver_now
    else
      AlarmMailer.member_alarm_notification(alarm_uuid, user_uuid).deliver_now
    end
  end
end
