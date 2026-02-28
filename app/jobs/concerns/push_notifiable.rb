module PushNotifiable
  private

  def send_push_notification(user, payload)
    subscriptions = user.web_push_subscriptions
    return if subscriptions.empty?

    subscriptions.each do |subscription|
      WebPush.payload_send(
        message:  payload.to_json,
        endpoint: subscription.endpoint,
        p256dh:   subscription.p256dh,
        auth:     subscription.auth,
        vapid: {
          subject:     ENV["VAPID_SUBJECT"],
          public_key:  ENV["VAPID_PUBLIC_KEY"],
          private_key: ENV["VAPID_PRIVATE_KEY"]
        }
      )
    rescue WebPush::ExpiredSubscription
      # （410 Gone）購読が永続的に無効になった場合、今後も届かないため削除する。
      Rails.logger.info("[PushNotification] 購読期限切れのため削除: #{subscription.endpoint}")
      subscription.destroy
    rescue WebPush::ResponseError => e
      # またジョブ全体をエラーにしないことでメールの重複送信を防ぐ。
      Rails.logger.error(
        "[PushNotification] 送信失敗 user=#{user.uuid} error=#{e.class}: #{e.message}"
      )
    end
  end
end
