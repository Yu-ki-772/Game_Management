# app/models/web_push_subscription.rb

class WebPushSubscription < ApplicationRecord
  belongs_to :user, foreign_key: :user_uuid, primary_key: :uuid

  validates :endpoint, presence: true, uniqueness: { scope: :user_uuid }
  validates :p256dh,   presence: true
  validates :auth,     presence: true
end