# spec/models/user_spec.rb
require "rails_helper"

RSpec.describe User, type: :model do
  subject { build(:user) }

  # ============================================================
  # アソシエーション
  # ============================================================
  describe "associations" do
    it do
      is_expected.to have_many(:alarms)
        .with_primary_key(:uuid)
        .with_foreign_key(:user_uuid)
        .dependent(:destroy)
    end

    it { is_expected.to have_many(:alarm_logs).through(:alarms) }

    it do
      is_expected.to have_many(:direct_alarm_logs)
        .class_name("AlarmLog")
        .with_foreign_key(:user_uuid)
        .with_primary_key(:uuid)
        .dependent(:destroy)
    end

    it do
      is_expected.to have_many(:message_templates)
        .with_primary_key(:uuid)
        .with_foreign_key(:user_uuid)
        .dependent(:destroy)
    end

    it do
      is_expected.to have_many(:bookmarks)
        .with_primary_key(:uuid)
        .with_foreign_key(:user_uuid)
        .dependent(:destroy)
    end

    it do
      is_expected.to have_many(:friendships)
        .with_primary_key(:uuid)
        .with_foreign_key(:user_uuid)
        .dependent(:destroy)
    end

    it do
      is_expected.to have_many(:received_friendships)
        .class_name("Friendship")
        .with_primary_key(:uuid)
        .with_foreign_key(:friend_uuid)
        .dependent(:destroy)
    end

    it do
      is_expected.to have_many(:alarm_memberships)
        .with_foreign_key(:user_uuid)
        .with_primary_key(:uuid)
        .dependent(:destroy)
    end

    it { is_expected.to have_many(:member_alarms).through(:alarm_memberships).source(:alarm) }

    it do
      is_expected.to have_many(:bookmarks_message_templates)
        .through(:bookmarks)
        .source(:message_template)
    end


    it do
      is_expected.to have_many(:web_push_subscriptions)
        .with_foreign_key(:user_uuid)
        .with_primary_key(:uuid)
        .dependent(:destroy)
    end

    it do
      is_expected.to have_many(:diagnosis_results)
        .with_primary_key(:uuid)
        .with_foreign_key(:user_uuid)
        .dependent(:destroy)
    end

    it { is_expected.to have_one_attached(:avatar) }
  end

  # ============================================================
  # バリデーション
  # ============================================================
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_length_of(:description).is_at_most(255) }


    # uid は `if: -> { uid.present? }` で条件付きのため、存在する場合・しない場合を分けて検証
    context "uid が存在する場合" do
      # OAuthユーザーの状態定義はファクトリの trait に集約
      subject { build(:user, :with_oauth) }

      it { is_expected.to validate_uniqueness_of(:uid).scoped_to(:provider) }
    end

    context "uid が存在しない場合" do
      subject { build(:user, uid: nil) }

      it "有効である" do
        expect(subject).to be_valid
      end
    end

    describe "avatar_content_type のバリデーション" do
      context "jpeg または png が添付されている場合" do
        it "有効と判定される" do
          user = build(:user)
          blob_double = double("blob", byte_size: 1.megabyte)
          attachment_double = double("attachment",
            attached?: true,
            content_type: "image/jpeg",
            blob: blob_double
          )
          allow(user).to receive(:avatar).and_return(attachment_double)

          user.valid?
          expect(user.errors[:avatar]).to be_empty
        end
      end

      context "jpeg・png 以外のファイルが添付されている場合" do
        it "エラーが追加される" do
          user = build(:user)
          blob_double = double("blob", byte_size: 1.megabyte)
          attachment_double = double("attachment",
            attached?: true,
            content_type: "image/gif",
            blob: blob_double
          )
          allow(user).to receive(:avatar).and_return(attachment_double)

          user.valid?
          expect(user.errors[:avatar]).not_to be_empty
        end
      end

      context "アバターが添付されていない場合" do
        it "バリデーションはスキップされる" do
          user = build(:user)
          attachment_double = double("attachment", attached?: false)
          allow(user).to receive(:avatar).and_return(attachment_double)

          user.valid?
          expect(user.errors[:avatar]).to be_empty
        end
      end
    end

    describe "avatar_size のバリデーション" do
      context "2MB 以内の場合" do
        it "有効と判定される" do
          user = build(:user)
          blob_double = double("blob", byte_size: 1.megabyte)
          attachment_double = double("attachment",
            attached?: true,
            blob: blob_double,
            content_type: "image/jpeg"
          )
          allow(user).to receive(:avatar).and_return(attachment_double)

          user.valid?
          expect(user.errors[:avatar]).to be_empty
        end
      end

      context "2MB を超える場合" do
        it "エラーが追加される" do
          user = build(:user)
          blob_double = double("blob", byte_size: 3.megabytes)
          attachment_double = double("attachment",
            attached?: true,
            blob: blob_double,
            content_type: "image/jpeg"
          )
          allow(user).to receive(:avatar).and_return(attachment_double)

          user.valid?
          expect(user.errors[:avatar]).not_to be_empty
        end
      end
    end
  end
end
