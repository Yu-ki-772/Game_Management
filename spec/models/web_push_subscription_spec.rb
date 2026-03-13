# spec/models/web_push_subscription_spec.rb
require "rails_helper"

RSpec.describe WebPushSubscription, type: :model do
  subject { build(:web_push_subscription) }

  # ============================================================
  # アソシエーション
  # ============================================================
  describe "associations" do
    it do
      is_expected.to belong_to(:user)
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
      is_expected.to validate_uniqueness_of(:endpoint)
        .ignoring_case_sensitivity # endpoint はDBに保存時に小文字へ正規化される可能性があるため、大文字での一意性検証を無効化
    end
  end
end
