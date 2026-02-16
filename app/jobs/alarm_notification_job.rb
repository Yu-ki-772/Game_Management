class AlarmNotificationJob < ApplicationJob
  queue_as :default

  # ネットワークエラーのエラーハンドリング
  retry_on Net::OpenTimeout, Net::ReadTimeout, wait: 5.seconds, attempts: 5

  def perform(alarm_uuid)
    alarm = Alarm.find_by(uuid: alarm_uuid)
    return unless alarm

    # 既に送信済みの場合はスキップ
    return if alarm.sent?

    # メールを送信
    AlarmMailer.alarm_notification(alarm_uuid).deliver_now

    # 送信完了後にsentをtrueに更新(Alarmのコールバックが実行されない記法)
    alarm.update_column(:sent, true)
  end
end
