# spec/models/web_push_subscription_spec.rb
require "rails_helper"

RSpec.describe WebPushSubscription do
  subject { build(:web_push_subscription) }

  # ============================================================
  # アソシエーション
  # ============================================================
  describe "associations" do
    it do
      expect(subject).to belong_to(:user)
        .with_foreign_key(:user_uuid)
        .with_primary_key(:uuid)
    end
  end

  # ============================================================
  # バリデーション
  # ============================================================
  describe "validations" do
    it { is_expected.to validate_presence_of(:endpoint) }
    it { is_expected.to validate_presence_of(:p256dh) }
    it { is_expected.to validate_presence_of(:auth) }

    it do
      expect(subject).to validate_uniqueness_of(:endpoint)
        .ignoring_case_sensitivity # UUID はDBに保存時に小文字へ正規化されるのに対し、shoulda-matchers が大文字で一意性を検証しようとし失敗するため、大文字での一意性検証を無効化。
    end
  end
end
