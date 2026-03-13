# spec/factories/alarm_memberships.rb
FactoryBot.define do
  factory :alarm_membership do
    association :alarm
    alarm_uuid { alarm.uuid }
    user       { alarm.creator }
    user_uuid  { alarm.creator.uuid }
  end
end
