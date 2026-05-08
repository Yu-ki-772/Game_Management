class AlarmMemberNotificationJob < ApplicationJob
  include PushNotifiable

  queue_as :default
  retry_on Net::OpenTimeout, Net::ReadTimeout, wait: 5.seconds, attempts: 5

  def perform(alarm_uuid, user_uuid)
    alarm = Alarm.find_by(uuid: alarm_uuid)
    unless alarm
      Rails.logger.warn("[AlarmMemberNotificationJob] アラームが見つかりません uuid=#{alarm_uuid}")
      return
    end

    if alarm.alarm_logs.exists?(user_uuid: user_uuid)
      Rails.logger.warn("[AlarmMemberNotificationJob] ストップ済みのためスキップ user=#{user_uuid}")
      return
    end

    membership = alarm.alarm_memberships.find_by(user_uuid: user_uuid)
    unless membership
      Rails.logger.warn("[AlarmMemberNotificationJob] メンバーシップが見つかりません user=#{user_uuid}")
      return
    end

    # 通知済みかどうかのチェック
    if membership.notified?
      Rails.logger.warn("[AlarmMemberNotificationJob] 送信済みフラグが立っているためスキップ user=#{user_uuid} notified_at=#{membership.updated_at}")
      return
    end

    user = User.find_by(uuid: user_uuid)
    unless user
      Rails.logger.warn("[AlarmMemberNotificationJob] ユーザーが見つかりません uuid=#{user_uuid}")
      return
    end

    Rails.logger.info("[AlarmMemberNotificationJob] send_push_notification を呼び出します user=#{user_uuid}")
    send_push_notification(user, build_alarm_payload(alarm, membership))
    membership.update!(notified: true)
  end

  private

  # プッシュ通知で届けるもの
  def build_alarm_payload(alarm, membership)
    {
      title: "⏰ アラーム",
      body:  "ゲーム終了の時間になりました",
      icon:  "/icon-192x192.png",
      url:   "/alarms/#{alarm.uuid}/alarm_memberships/#{membership.id}"
    }
  end
end
