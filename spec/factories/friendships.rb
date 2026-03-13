# spec/factories/friendships.rb
FactoryBot.define do
  factory :friendship do
    association :user
    association :friend, factory: :user
    user_uuid   { user.uuid }
    friend_uuid { friend.uuid }
    # status のデフォルトは pending
  end
end