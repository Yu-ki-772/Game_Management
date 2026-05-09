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


  describe "instance methods" do
    # ----------------------------------------------------------
    # #stopped?
    # ----------------------------------------------------------
    describe "#stopped?" do
      context "ユーザーがアラームをストップ済みの場合" do
        it "true を返す" do
          alarm      = create(:alarm)
          membership = alarm.alarm_memberships.first
          # alarm_log を直接作成してストップ済みの状態を作る
          alarm.alarm_logs.create!(
            user_uuid:         membership.user_uuid,
            stopped_at:       Time.current,
            minutes_to_stop: 0
          )

          expect(membership.stopped?).to be true
        end
      end

      context "ユーザーがアラームをストップしていない場合" do
        it "false を返す" do
          alarm      = create(:alarm)
          membership = alarm.alarm_memberships.first

          expect(membership.stopped?).to be false
        end
      end
    end

    describe "#stop" do
      context "すでにストップ済みの場合" do
        it "false を返す" do
          alarm      = create(:alarm)
          membership = alarm.alarm_memberships.first

          # 事前にストップ済みの状態を作る
          alarm.alarm_logs.create!(
            user_uuid:         membership.user_uuid,
            stopped_at:       Time.current,
            minutes_to_stop: 0
          )

          expect(membership.stop).to be false
        end
      end

      context "AlarmLog のバリデーションが失敗する場合" do
        it "false を返す" do
          alarm = create(:alarm, scheduled_at: 25.hours.from_now)
          alarm.update_column(:scheduled_at, 25.hours.ago)
          membership = alarm.alarm_memberships.first

          expect(membership.stop).to be false
        end
      end

      context "正常にストップできた場合" do
        it "AlarmLog を返す" do
          alarm      = create(:alarm)
          alarm.update_column(:scheduled_at, 1.minute.ago)
          membership = alarm.alarm_memberships.first

          result = membership.stop

          expect(result).to be_a(AlarmLog)
        end

        it "AlarmLog が DB に保存される" do
          alarm      = create(:alarm)
          alarm.update_column(:scheduled_at, 1.minute.ago)
          membership = alarm.alarm_memberships.first

          expect { membership.stop }.to change(AlarmLog, :count).by(1)
        end
      end

      context "全員がストップ済みになった場合" do
        it "alarm.stopped が true になる" do
          alarm      = create(:alarm)
          alarm.update_column(:scheduled_at, 1.minute.ago)
          membership = alarm.alarm_memberships.first

          membership.stop

          expect(alarm.reload.stopped).to be true
        end
      end

      context "まだ全員がストップ済みでない場合" do
        it "alarm.stopped は false のまま" do
          alarm      = create(:alarm)
          alarm.update_column(:scheduled_at, 1.minute.ago)
          membership = alarm.alarm_memberships.first

          allow(membership).to receive(:all_members_stopped?).and_return(false)

          membership.stop

          expect(alarm.reload.stopped).to be false
        end
      end
    end
  end
end
