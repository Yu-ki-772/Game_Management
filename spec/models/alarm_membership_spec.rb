# spec/models/alarm_membership_spec.rb
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
    describe "user_must_be_friend_of_creator" do
      context "ユーザーがアラームの作成者である場合（creator? が true）" do
        it "有効である" do
          expect(subject).to be_valid
        end
      end

      context "ユーザーがアラームの作成者でない場合（creator? が false）" do
        let(:creator)    { create(:user) }
        let(:alarm)      { create(:alarm, creator: creator) }
        let(:member)     { create(:user) }
        let(:membership) { build(:alarm_membership, alarm: alarm, user: member, user_uuid: member.uuid) }

        context "作成者とフレンド関係にある場合" do
          before do
            create(:friendship, user: creator, friend: member, status: :accepted)
          end

          it "有効である" do
            expect(membership).to be_valid
          end
        end

        context "作成者とフレンド関係にない場合" do
          it "user_uuid にエラーが追加される" do
            membership.valid?
            expect(membership.errors[:user_uuid]).not_to be_empty
          end
        end
      end
    end
  end

  describe "instance methods" do
    # ----------------------------------------------------------
    # #stopped?
    # ----------------------------------------------------------
    describe "#stopped?" do
      let(:alarm)      { create(:alarm) }
      let(:membership) { alarm.alarm_memberships.first }

      context "ユーザーがアラームをストップ済みの場合" do
        before do
          create(:alarm_log, alarm: alarm, user_uuid: membership.user_uuid)
        end

        it "true を返す" do
          expect(membership.stopped?).to be true
        end
      end

      context "ユーザーがアラームをストップしていない場合" do
        it "false を返す" do
          expect(membership.stopped?).to be false
        end
      end
    end

    describe "#stop" do
      let(:alarm)      { create(:alarm) }
      let(:membership) { alarm.alarm_memberships.first }

      context "すでにストップ済みの場合" do
        before do
          create(:alarm_log, alarm: alarm, user_uuid: membership.user_uuid)
        end

        it "false を返す" do
          expect(membership.stop).to be false
        end
      end

      context "AlarmLog のバリデーションが失敗する場合" do
        before do
          alarm.update_column(:scheduled_at, 300.minutes.ago) # 境界値: 300分超でバリデーションが失敗する
        end

        it "false を返す" do
          expect(membership.stop).to be false
        end
      end

      context "AlarmLog のバリデーションが通過する場合" do
        before do
          alarm.update_column(:scheduled_at, 299.minutes.ago) # 境界値: 299分以内でバリデーションが通る
        end

        it "AlarmLog を返す" do
          expect(membership.stop).to be_a(AlarmLog)
        end
      end

      context "正常にストップできた場合" do
        it "AlarmLog を返す" do
          expect(membership.stop).to be_a(AlarmLog)
        end

        it "AlarmLog が DB に保存される" do
          expect { membership.stop }.to change(AlarmLog, :count).by(1)
        end
      end

      context "全員がストップ済みになった場合" do
        it "alarm.stopped が true になる" do
          membership.stop
          expect(alarm.reload.stopped).to be true
        end
      end

      context "まだ全員がストップ済みでない場合" do
        it "alarm.stopped は false のまま" do
          allow(membership).to receive(:all_members_stopped?).and_return(false)
          membership.stop
          expect(alarm.reload.stopped).to be false
        end
      end
    end
  end
end