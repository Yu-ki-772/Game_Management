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

  # spec/models/user_spec.rb（既存ファイルに追記）

  # ============================================================
  # インスタンスメソッド
  # ============================================================
  describe "instance methods" do

    # ----------------------------------------------------------
    # #send_friend_request
    # ----------------------------------------------------------
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

    # ----------------------------------------------------------
    # #pending_request_from?
    # ----------------------------------------------------------
    describe "#pending_request_from?" do
      context "対象ユーザから pending のフレンドリクエストが来ている場合" do
        it "その Friendship を返す" do
          user       = create(:user)
          other_user = create(:user)
          # other_user → user への pending リクエストを作成する
          friendship = create(:friendship, user: other_user, friend: user)

          expect(user.pending_request_from?(other_user)).to eq(friendship)
        end
      end

      context "対象ユーザからフレンドリクエストが来ていない場合" do
        it "nil を返す" do
          user       = create(:user)
          other_user = create(:user)

          expect(user.pending_request_from?(other_user)).to be_nil
        end
      end
    end

    # ----------------------------------------------------------
    # #friendship_with
    # ----------------------------------------------------------
    describe "#friendship_with" do
      context "対象ユーザとの Friendship が存在する場合" do
        it "その Friendship を返す" do
          user       = create(:user)
          other_user = create(:user)
          friendship = create(:friendship, user: user, friend: other_user)

          expect(user.friendship_with(other_user)).to eq(friendship)
        end
      end

      context "対象ユーザとの Friendship が存在しない場合" do
        it "nil を返す" do
          user       = create(:user)
          other_user = create(:user)

          expect(user.friendship_with(other_user)).to be_nil
        end
      end
    end

    # ----------------------------------------------------------
    # #bookmark / #unbookmark
    # ----------------------------------------------------------
    describe "#bookmark" do
      it "message_template をブックマークに追加する" do
        user             = create(:user)
        message_template = create(:message_template)

        user.bookmark(message_template)

        expect(user.bookmarks_message_templates).to include(message_template)
      end
    end

    describe "#unbookmark" do
      it "message_template をブックマークから削除する" do
        user             = create(:user)
        message_template = create(:message_template)

        # 事前にブックマークしておく
        user.bookmark(message_template)
        user.unbookmark(message_template)

        expect(user.bookmarks_message_templates).not_to include(message_template)
      end
    end

    # ----------------------------------------------------------
    # #avatar_image?
    # ----------------------------------------------------------
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
