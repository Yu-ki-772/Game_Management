# spec/factories/users.rb
FactoryBot.define do
  # SecureRandom.uuid はランダムなuuidを生成
  # Faker::Name.name はランダムな人名を返す
  # Faker::Internet.unique.email はユニークなメールアドレスを生成

  factory :user do
    uuid     { SecureRandom.uuid }
    name     { Faker::Name.name }
    email    { Faker::Internet.unique.email }
    password { "Password123!" }

    # OAuthログインユーザーを作りたい場合は trait を指定する
    trait :with_oauth do
      uid      { SecureRandom.uuid }
      provider { "google_oauth2" }
    end

    # 管理者ユーザーを作りたい場合はこのtraitを使う
    trait :admin do
      admin { true }
    end
  end
end
