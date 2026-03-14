# spec/models/friendship_spec.rb
require "rails_helper"

RSpec.describe Friendship, type: :model do
  subject { build(:friendship) }

  # ============================================================
  # アソシエーション
  # ============================================================
  describe "associations" do
    it do
      is_expected.to belong_to(:user)
        .with_primary_key(:uuid)
        .with_foreign_key(:user_uuid)
    end

    it do
      is_expected.to belong_to(:friend)
        .class_name("User")
        .with_primary_key(:uuid)
        .with_foreign_key(:friend_uuid)
    end
  end

  # ============================================================
  # バリデーション
  # ============================================================
  describe "validations" do
    it do
      is_expected.to validate_uniqueness_of(:user_uuid)
        .scoped_to(:friend_uuid)
        .ignoring_case_sensitivity # UUID はDBに保存時に小文字へ正規化されるため、大文字での一意性検証を無効化
    end
  end

  # ============================================================
  # enum
  # ============================================================
  describe "enum" do
    it "status は pending と accepted の値を持つ" do
      expect(Friendship.statuses).to eq({ "pending" => "pending", "accepted" => "accepted" })
    end

    it "status のデフォルトは pending である" do
      expect(build(:friendship).status).to eq("pending")
    end
  end


  describe "instance methods" do
    describe "#partner" do
      context "accepted 状態でない場合（pending）" do
        it "nil を返す" do
          user       = create(:user)
          other_user = create(:user)
          # statusのデフォルトは pending
          friendship = create(:friendship, user: user, friend: other_user)

          expect(friendship.partner(user)).to be_nil
        end
      end

      context "accepted 状態の場合" do
        context "渡したユーザーが申請者（user_uuid 側）の場合" do
          it "friend を返す" do
            user       = create(:user)
            other_user = create(:user)
            friendship = create(:friendship,
              user:   user,
              friend: other_user,
              status: :accepted
            )

            expect(friendship.partner(user)).to eq(other_user)
          end
        end

        context "渡したユーザーが受け取り側（friend_uuid 側）の場合" do
          it "user を返す" do
            user       = create(:user)
            other_user = create(:user)
            friendship = create(:friendship,
              user:   user,
              friend: other_user,
              status: :accepted
            )

            expect(friendship.partner(other_user)).to eq(user)
          end
        end
      end
    end
  end
end
