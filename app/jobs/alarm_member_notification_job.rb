class AlarmMemberNotificationJob < ApplicationJob
  include PushNotifiable

  queue_as :default

  retry_on Net::OpenTimeout, Net::ReadTimeout, wait: 5.seconds, attempts: 5

  def perform(alarm_uuid, user_uuid)
    alarm = Alarm.find_by(uuid: alarm_uuid)
    return unless alarm

    return if alarm.alarm_logs.exists?(user_uuid: user_uuid)

    membership = alarm.alarm_memberships.find_by(user_uuid: user_uuid)
    return unless membership

    # 通知済みかどうかのチェック
    return if membership.notified?

    # メール・プッシュ通知より先に送信済みとして記録（エラー時のリトライによる二重送信対策）
    membership.update!(notified: true)

    user = User.find_by(uuid: user_uuid)
    return unless user

    send_push_notification(user, build_alarm_payload(alarm))
  end

  private

  # プッシュ通知で届けるもの
  def build_alarm_payload(alarm)
    {
      title: "⏰ アラーム",
      body:  "ゲーム終了の時間になりました",
      icon:  "/icon-192x192.png"
    }
  end
end