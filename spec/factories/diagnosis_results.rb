# spec/factories/diagnosis_results.rb
FactoryBot.define do
  factory :diagnosis_result do
    association :user
    user_uuid         { user.uuid }
    control_score     { 10 }
    life_score        { 10 }
    quality_score     { 10 }
    consistency_score { 10 }
    total_score       { 40 }
  end
end
