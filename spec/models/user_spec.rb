# spec/models/user_spec.rb
require "rails_helper"

RSpec.describe User do
  subject { build(:user) }

  # ============================================================
  # アソシエーション
  # ============================================================
  describe "associations" do
    it do
      expect(subject).to have_many(:alarms)
        .with_primary_key(:uuid)
        .with_foreign_key(:user_uuid)
        .dependent(:destroy)
    end

    it { is_expected.to have_many(:alarm_logs).through(:alarms) }

    it do
      expect(subject).to have_many(:direct_alarm_logs)
        .class_name("AlarmLog")
        .with_foreign_key(:user_uuid)
        .with_primary_key(:uuid)
        .dependent(:destroy)
    end

    it do
      expect(subject).to have_many(:message_templates)
        .with_primary_key(:uuid)
        .with_foreign_key(:user_uuid)
        .dependent(:destroy)
    end

    it do
      expect(subject).to have_many(:bookmarks)
        .with_primary_key(:uuid)
        .with_foreign_key(:user_uuid)
        .dependent(:destroy)
    end

    it do
      expect(subject).to have_many(:friendships)
        .with_primary_key(:uuid)
        .with_foreign_key(:user_uuid)
        .dependent(:destroy)
    end

    it do
      expect(subject).to have_many(:received_friendships)
        .class_name("Friendship")
        .with_primary_key(:uuid)
        .with_foreign_key(:friend_uuid)
        .dependent(:destroy)
    end

    it do
      expect(subject).to have_many(:alarm_memberships)
        .with_foreign_key(:user_uuid)
        .with_primary_key(:uuid)
        .dependent(:destroy)
    end

    it { is_expected.to have_many(:member_alarms).through(:alarm_memberships).source(:alarm) }

    it do
      expect(subject).to have_many(:bookmarks_message_templates)
        .through(:bookmarks)
        .source(:message_template)
    end

    it do
      expect(subject).to have_many(:web_push_subscriptions)
        .with_foreign_key(:user_uuid)
        .with_primary_key(:uuid)
        .dependent(:destroy)
    end

    it do
      expect(subject).to have_many(:diagnosis_results)
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

  # ============================================================
  # スコープ
  # ============================================================
  describe "scopes" do
    describe ".non_admin" do
      let!(:normal_user) { create(:user) }
      let!(:admin_user)  { create(:user, :admin) }

      it "管理者ユーザーを含まない" do
        expect(described_class.non_admin).not_to include(admin_user)
      end

      it "一般ユーザーを含む" do
        expect(described_class.non_admin).to include(normal_user)
      end
    end
  end

  # ============================================================
  # インスタンスメソッド
  # ============================================================
  describe "instance methods" do
    describe "#send_friend_request" do
      let(:user)       { create(:user) }
      let(:other_user) { create(:user) }
      let(:friendship) { user.send_friend_request(other_user) }

      it "Friendship が DB に保存される" do
        expect(friendship).to be_persisted
      end

      it "friend が other_user である" do
        expect(friendship.friend).to eq(other_user)
      end

      it "status が pending である" do
        expect(friendship.status).to eq("pending")
      end
    end

    describe "#pending_request_from?" do
      let(:user)       { create(:user) }
      let(:other_user) { create(:user) }

      context "対象ユーザから pending のフレンドリクエストが来ている場合" do
        it "その Friendship を返す" do
          # other_user → user への pending リクエストを作成する
          friendship = create(:friendship, user: other_user, friend: user)
          expect(user.pending_request_from?(other_user)).to eq(friendship)
        end
      end

      context "対象ユーザからフレンドリクエストが来ていない場合" do
        it "nil を返す" do
          expect(user.pending_request_from?(other_user)).to be_nil
        end
      end
    end

    describe "#friendship_with" do
      let(:user)       { create(:user) }
      let(:other_user) { create(:user) }

      context "対象ユーザとの Friendship が存在する場合" do
        it "その Friendship を返す" do
          friendship = create(:friendship, user: user, friend: other_user)
          expect(user.friendship_with(other_user)).to eq(friendship)
        end
      end

      context "対象ユーザとの Friendship が存在しない場合" do
        it "nil を返す" do
          expect(user.friendship_with(other_user)).to be_nil
        end
      end
    end

    describe "#bookmark" do
      let(:user)             { create(:user) }
      let(:message_template) { create(:message_template) }

      it "message_template をブックマークに追加する" do
        user.bookmark(message_template)
        expect(user.bookmarks_message_templates).to include(message_template)
      end
    end

    describe "#unbookmark" do
      let(:user)             { create(:user) }
      let(:message_template) { create(:message_template) }

      it "message_template をブックマークから削除する" do
        user.bookmark(message_template) # 事前にブックマークしておく
        user.unbookmark(message_template)
        expect(user.bookmarks_message_templates).not_to include(message_template)
      end
    end

    describe "#avatar_image?" do
      context "jpeg または png が添付されている場合" do
        it "true を返す" do
          user = build(:user)
          attachment_double = double("attachment",
            attached?: true,
            content_type: "image/jpeg"
          )
          allow(user).to receive(:avatar).and_return(attachment_double)

          expect(user.avatar_image?).to be true
        end
      end

      context "jpeg・png 以外のファイルが添付されている場合" do
        it "false を返す" do
          user = build(:user)
          attachment_double = double("attachment",
            attached?: true,
            content_type: "image/gif"
          )
          allow(user).to receive(:avatar).and_return(attachment_double)

          expect(user.avatar_image?).to be false
        end
      end

      context "アバターが添付されていない場合" do
        it "false を返す" do
          user = build(:user)
          attachment_double = double("attachment", attached?: false)
          allow(user).to receive(:avatar).and_return(attachment_double)

          expect(user.avatar_image?).to be false
        end
      end
    end
  end
end
