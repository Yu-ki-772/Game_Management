# spec/models/message_template_spec.rb
require "rails_helper"

RSpec.describe MessageTemplate, type: :model do
  subject { build(:message_template) }

  # ============================================================
  # アソシエーション
  # ============================================================
  describe "associations" do
    it do
      is_expected.to belong_to(:user)
        .with_primary_key(:uuid)
        .with_foreign_key(:user_uuid)
        .optional
    end

    it { is_expected.to have_many(:bookmarks).dependent(:destroy) }
  end

  # ============================================================
  # バリデーション
  # ============================================================
  describe "validations" do
    # ---- reason ----
    it { is_expected.to validate_presence_of(:reason) }
    it { is_expected.to validate_length_of(:reason).is_at_most(255) }

    # ---- template ----
    it { is_expected.to validate_presence_of(:template) }
    it { is_expected.to validate_length_of(:template).is_at_most(255) }
  end
end