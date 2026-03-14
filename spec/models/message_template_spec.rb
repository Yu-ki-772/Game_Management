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


  describe "class methods" do
    describe ".existing_reasons" do
      let(:user)       { create(:user) }
      let(:other_user) { create(:user) }

      before do
        # 指定ユーザーのテンプレート
        create(:message_template, user_uuid: user.uuid,       reason: "自分の理由")
        # 共通テンプレート（user_uuid: nil）
        create(:message_template, user_uuid: nil,             reason: "共通の理由")
        # 他ユーザーのテンプレート（含まれないはず）
        create(:message_template, user_uuid: other_user.uuid, reason: "他人の理由")
      end

      it "指定ユーザーの理由が含まれる" do
        expect(MessageTemplate.existing_reasons(user.uuid)).to include("自分の理由")
      end

      it "共通テンプレートの理由が含まれる" do
        expect(MessageTemplate.existing_reasons(user.uuid)).to include("共通の理由")
      end

      it "他ユーザーの理由は含まれない" do
        expect(MessageTemplate.existing_reasons(user.uuid)).not_to include("他人の理由")
      end

      it "重複した理由は1件だけ返す" do
        # 同じ理由を持つテンプレートをもう1件作成する
        create(:message_template, user_uuid: user.uuid, reason: "自分の理由")
        reasons = MessageTemplate.existing_reasons(user.uuid)
        expect(reasons.count("自分の理由")).to eq(1)
      end
    end
  end
end
