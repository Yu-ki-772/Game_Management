# spec/factories/message_templates.rb
FactoryBot.define do
  factory :message_template do
    association :user
    user_uuid { user.uuid }
    reason   { Faker::Lorem.sentence }
    template { Faker::Lorem.sentence }
  end
end