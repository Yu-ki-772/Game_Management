# spec/factories/bookmarks.rb
FactoryBot.define do
  factory :bookmark do
    association :user
    association :message_template
    user_uuid { user.uuid }
  end
end
