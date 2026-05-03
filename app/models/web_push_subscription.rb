# app/models/web_push_subscription.rb

class WebPushSubscription < ApplicationRecord
  belongs_to :user, foreign_key: :user_uuid, primary_key: :uuid

  validates :endpoint, presence: true, uniqueness: true
  validates :p256dh,   presence: true
  validates :auth,     presence: true

  ## 通知購読データのDBへの保存or更新
  def self.subscribe(endpoint:, user:, p256dh:, auth:)
    upsert(
      {
        endpoint:  endpoint,
        user_uuid: user.uuid,
        p256dh:    p256dh,
        auth:      auth
      },
      unique_by: :endpoint,
      record_timestamps: true
    )
  end
end
