FactoryBot.define do
  factory :alarm do
    uuid         { SecureRandom.uuid }
    association :creator, factory: :user
    user_uuid    { creator.uuid } 
    label       { "アラーム" }
    scheduled_at { 1.hour.from_now }

    # started_at がある状態用のtrait
    trait :with_started_at do
      started_at { Time.current }
    end
  end
end
