class AlarmNotificationJob < ApplicationJob
  queue_as :default

  retry_on Net::OpenTimeout, Net::ReadTimeout, wait: 5.seconds, attempts: 5

  def perform(alarm_uuid)
    alarm = Alarm.find_by(uuid: alarm_uuid)
    return unless alarm
    # 既に送信済みの場合はスキップ
    return if alarm.sent?

    # 作成者への通知（既存の処理）
    AlarmMailer.alarm_notification(alarm_uuid).deliver_now

    # メンバーへの通知を1人ずつ送る。
    alarm.members.includes(:alarm_memberships).each do |member|
      AlarmMailer.member_alarm_notification(alarm_uuid, member.uuid).deliver_now
    end

    alarm.update_column(:sent, true)
  end
end