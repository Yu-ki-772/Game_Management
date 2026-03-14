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
    before do
      allow_any_instance_of(Alarm).to receive(:schedule_notification_job)
    end

    # ----------------------------------------------------------
    # #unlocked?
    # ----------------------------------------------------------
    describe "#unlocked?" do
      context "ユーザーがアラームをストップ済みの場合" do
        it "true を返す" do
          alarm      = create(:alarm)
          membership = alarm.alarm_memberships.first
          # alarm_log を直接作成してストップ済みの状態を作る
          alarm.alarm_logs.create!(
            user_uuid:         membership.user_uuid,
            unlocked_at:       Time.current,
            minutes_to_unlock: 0
          )

          expect(membership.unlocked?).to be true
        end
      end

      context "ユーザーがアラームをストップしていない場合" do
        it "false を返す" do
          alarm      = create(:alarm)
          membership = alarm.alarm_memberships.first

          expect(membership.unlocked?).to be false
        end
      end
    end

    describe "#unlock" do
      context "すでにアンロック済みの場合" do
        it "false を返す" do
          alarm      = create(:alarm)
          membership = alarm.alarm_memberships.first

          # 事前にアンロック済みの状態を作る
          alarm.alarm_logs.create!(
            user_uuid:         membership.user_uuid,
            unlocked_at:       Time.current,
            minutes_to_unlock: 0
          )

          expect(membership.unlock).to be false
        end
      end

      context "AlarmLog のバリデーションが失敗する場合" do
        it "false を返す" do
          alarm = create(:alarm, scheduled_at: 25.hours.from_now)
          alarm.update_column(:scheduled_at, 25.hours.ago)
          membership = alarm.alarm_memberships.first

          expect(membership.unlock).to be false
        end
      end

      context "正常にアンロックできた場合" do
        it "AlarmLog を返す" do
          alarm      = create(:alarm)
          alarm.update_column(:scheduled_at, 1.minute.ago)
          membership = alarm.alarm_memberships.first

          result = membership.unlock

          expect(result).to be_a(AlarmLog)
        end

        it "AlarmLog が DB に保存される" do
          alarm      = create(:alarm)
          alarm.update_column(:scheduled_at, 1.minute.ago)
          membership = alarm.alarm_memberships.first

          expect { membership.unlock }.to change(AlarmLog, :count).by(1)
        end
      end

      context "全員がアンロック済みになった場合" do
        it "alarm.unlocked が true になる" do
          alarm      = create(:alarm)
          alarm.update_column(:scheduled_at, 1.minute.ago)
          membership = alarm.alarm_memberships.first

          membership.unlock

          expect(alarm.reload.unlocked).to be true
        end
      end

      context "まだ全員がアンロック済みでない場合" do
        it "alarm.unlocked は false のまま" do
          alarm      = create(:alarm)
          alarm.update_column(:scheduled_at, 1.minute.ago)
          membership = alarm.alarm_memberships.first

          allow(membership).to receive(:all_members_unlocked?).and_return(false)

          membership.unlock

          expect(alarm.reload.unlocked).to be false
        end
      end
    end
  end
end
