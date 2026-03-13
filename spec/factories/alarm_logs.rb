# spec/factories/alarm_logs.rb
FactoryBot.define do
  factory :alarm_log do
    association :alarm
    alarm_uuid        { alarm.uuid }
    minutes_to_unlock { 0 }
    unlocked_at       { Time.current }
  end
end