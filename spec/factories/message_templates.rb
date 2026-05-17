# spec/factories/message_templates.rb
FactoryBot.define do
  # Faker::Lorem.sentence でランダムな一文を生成
  factory :message_template do
    association :user
    user_uuid { user.uuid }
    reason   { Faker::Lorem.sentence }
    template { Faker::Lorem.sentence }

    # ユーザ登録時から存在する共通のデフォルト定型文
    trait :common do
      user      { nil }
      user_uuid { nil }
    end
  end
end
