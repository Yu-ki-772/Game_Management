# spec/factories/web_push_subscriptions.rb
FactoryBot.define do
  factory :web_push_subscription do
    association :user
    user_uuid { user.uuid }
    endpoint  { "https://example.com/push/#{SecureRandom.hex}" }

    # presence: true のみの検証のため普通のダミー文字列で十分
    p256dh    { "dummy_p256dh" }
    auth      { "dummy_auth" }
  end
end
