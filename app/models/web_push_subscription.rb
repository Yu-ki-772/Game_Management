# app/models/web_push_subscription.rb

class WebPushSubscription < ApplicationRecord
  belongs_to :user, foreign_key: :user_uuid, primary_key: :uuid

  
  validates :endpoint, presence: true, uniqueness: { scope: :user_uuid } # 同一ユーザーの重複登録を防ぐ。（※endpointはアプリケーションサーバーがプッシュメッセージを送信する宛先URL。）
  validates :p256dh,   presence: true
  validates :auth,     presence: true
end