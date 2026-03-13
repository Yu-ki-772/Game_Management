# spec/models/bookmark_spec.rb
require "rails_helper"

RSpec.describe Bookmark, type: :model do
  subject { build(:bookmark) }

  # ============================================================
  # アソシエーション
  # ============================================================
  describe "associations" do
    it do
      is_expected.to belong_to(:user)
        .with_primary_key(:uuid)
        .with_foreign_key(:user_uuid)
    end

    it { is_expected.to belong_to(:message_template) }
  end

  # ============================================================
  # バリデーション
  # ============================================================
  describe "validations" do
    it do
      is_expected.to validate_uniqueness_of(:user_uuid)
        .scoped_to(:message_template_id)
        .ignoring_case_sensitivity # UUID はDBに保存時に小文字へ正規化されるため、大文字での一意性検証を無効化
    end
  end
end
