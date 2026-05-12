# spec/factories/friendships.rb
FactoryBot.define do
  # statusカラム のデフォルト値は pending
  factory :friendship do
    association :user
    association :friend, factory: :user
    user_uuid   { user.uuid }
    friend_uuid { friend.uuid }
  end
end
