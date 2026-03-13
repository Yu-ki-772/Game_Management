# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    name     { Faker::Name.name }
    email    { Faker::Internet.unique.email }
    password { "Password123!" }

    # OAuthログインユーザーを作りたい場合は trait を指定する
    trait :with_oauth do
      uid      { SecureRandom.uuid }
      provider { "google_oauth2" }
    end
  end
end
