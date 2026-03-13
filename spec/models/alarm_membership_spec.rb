require "rails_helper"

RSpec.describe AlarmMembership, type: :model do
  subject { build(:alarm_membership) }

  # ============================================================
  # アソシエーション
  # ============================================================
  describe "associations" do

    it "user に belongs_to している" do
      reflection = AlarmMembership.reflect_on_association(:user)
      expect(reflection.macro).to eq(:belongs_to)
      expect(reflection.options[:foreign_key]).to eq("user_uuid")
      expect(reflection.options[:primary_key]).to eq("uuid")
    end

    it "alarm に belongs_to している" do
      reflection = AlarmMembership.reflect_on_association(:alarm)
      expect(reflection.macro).to eq(:belongs_to)
      expect(reflection.options[:foreign_key]).to eq("alarm_uuid")
      expect(reflection.options[:primary_key]).to eq("uuid")
    end
  end

  # ============================================================
  # バリデーション
  # ============================================================
  describe "validations" do

    # unless: :creator? で条件付きのため、作成者かどうかで分ける
    describe "user_must_be_friend_of_creator" do

      context "ユーザーがアラームの作成者である場合（creator? が true）" do
        it "有効である" do
          expect(subject).to be_valid
        end
      end

      context "ユーザーがアラームの作成者でない場合（creator? が false）" do
        let(:creator)    { build(:user) }
        let(:alarm)      { build(:alarm, creator: creator) }
        let(:member)     { build(:user) }
        let(:membership) { build(:alarm_membership, alarm: alarm, user: member, user_uuid: member.uuid) }

        let(:friendship_relation_double) { double }

        before do
          allow(Friendship).to receive(:accepted).and_return(friendship_relation_double)
          allow(friendship_relation_double).to receive(:between).and_return(friendship_relation_double)
        end

        context "作成者とフレンド関係にある場合" do
          before { allow(friendship_relation_double).to receive(:exists?).and_return(true) }

          it "有効である" do
            expect(membership).to be_valid
          end
        end

        context "作成者とフレンド関係にない場合" do
          before { allow(friendship_relation_double).to receive(:exists?).and_return(false) }

          it "user_uuid にエラーが追加される" do
            membership.valid?
            expect(membership.errors[:user_uuid]).not_to be_empty
          end
        end
      end
    end
  end
end