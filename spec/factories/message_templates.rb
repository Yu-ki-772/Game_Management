# spec/factories/message_templates.rb
FactoryBot.define do
  # Faker::Lorem.sentence でランダムな一文を生成
  factory :message_template do
    association :user
    user_uuid { user.uuid }
    reason   { Faker::Lorem.sentence }
    template { Faker::Lorem.sentence }
  end
end
