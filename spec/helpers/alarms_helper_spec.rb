# spec/helpers/alarms_helper_spec.rb
require "rails_helper"

RSpec.describe AlarmsHelper do
  include ActiveSupport::Testing::TimeHelpers

  describe "#stoppable?" do
    context "scheduled_at が現在時刻の前後 5 時間以内のとき" do
      it "true を返す" do
        alarm = build(:alarm, scheduled_at: 4.hours.from_now)
        expect(helper.stoppable?(alarm)).to be true
      end
    end

    context "scheduled_at がちょうど 5 時間前のとき" do
      it "true を返す" do
        alarm = build(:alarm, scheduled_at: 4.hours.from_now)
        travel_to(alarm.scheduled_at + 5.hours) do
          expect(helper.stoppable?(alarm)).to be true
        end
      end
    end

    context "scheduled_at が現在時刻から 5 時間を超えるとき" do
      it "false を返す" do
        alarm = build(:alarm, scheduled_at: 6.hours.from_now)
        expect(helper.stoppable?(alarm)).to be false
      end
    end

    context "scheduled_at が現在時刻より過去 5 時間以内のとき" do
      it "true を返す" do
        alarm = build(:alarm, scheduled_at: 4.hours.from_now)
        travel_to(alarm.scheduled_at + 3.hours) do
          expect(helper.stoppable?(alarm)).to be true
        end
      end
    end

    context "scheduled_at が現在時刻より過去 5 時間を超えるとき" do
      it "false を返す" do
        alarm = build(:alarm, scheduled_at: 4.hours.from_now)
        travel_to(alarm.scheduled_at + 6.hours) do
          expect(helper.stoppable?(alarm)).to be false
        end
      end
    end
  end

  describe "#reminder_label" do
    context "reminder_minutes が未設定のとき" do
      it "nil を返す" do
        alarm = build(:alarm, reminder_minutes: nil)
        expect(helper.reminder_label(alarm)).to be_nil
      end
    end

    context "reminder_minutes が 60 分未満のとき" do
      it "分で表示する" do
        alarm = build(:alarm, reminder_minutes: 30)
        expect(helper.reminder_label(alarm)).to eq("30分前にリマインダー")
      end
    end

    context "reminder_minutes が 60 分ちょうどのとき" do
      it "時間で表示する" do
        alarm = build(:alarm, reminder_minutes: 60)
        expect(helper.reminder_label(alarm)).to eq("1時間前にリマインダー")
      end
    end

    context "reminder_minutes が 60 分以上のとき" do
      it "時間で表示する" do
        alarm = build(:alarm, reminder_minutes: 120)
        expect(helper.reminder_label(alarm)).to eq("2時間前にリマインダー")
      end
    end
  end

  describe "#alarm_display_members" do
    let(:alarm) { create(:alarm) }

    def add_member(alarm)
      user = create(:user)
      create(:friendship, user: alarm.creator, friend: user, status: :accepted)
      create(:alarm_membership, alarm: alarm, alarm_uuid: alarm.uuid, user: user, user_uuid: user.uuid)
    end

    context "非作成者メンバーがいないとき" do
      it "空を返す" do
        alarm.members.reload
        expect(helper.alarm_display_members(alarm)).to be_empty
      end
    end

    context "非作成者メンバーが 3 人以下のとき" do
      before do
        2.times { add_member(alarm) }
        alarm.members.reload
      end

      it "全員を返す" do
        expect(helper.alarm_display_members(alarm).size).to eq(2)
      end
    end

    context "非作成者メンバーが 3 人を超えるとき" do
      before do
        4.times { add_member(alarm) }
        alarm.members.reload
      end

      it "3 件に絞って返す" do
        expect(helper.alarm_display_members(alarm).size).to eq(3)
      end
    end
  end

  describe "#alarm_hidden_members_count" do
    let(:alarm) { create(:alarm) }

    def add_member(alarm)
      user = create(:user)
      create(:friendship, user: alarm.creator, friend: user, status: :accepted)
      create(:alarm_membership, alarm: alarm, alarm_uuid: alarm.uuid, user: user, user_uuid: user.uuid)
    end

    context "非作成者メンバーがいないとき" do
      it "-3 を返す" do
        alarm.members.reload
        expect(helper.alarm_hidden_members_count(alarm)).to eq(-3)
      end
    end

    context "非作成者メンバーが 3 人以下のとき" do
      before do
        2.times { add_member(alarm) }
        alarm.members.reload
      end

      it "-1 を返す" do
        expect(helper.alarm_hidden_members_count(alarm)).to eq(-1)
      end
    end

    context "非作成者メンバーが 3 人を超えるとき" do
      before do
        4.times { add_member(alarm) }
        alarm.members.reload
      end

      it "超過人数を返す" do
        expect(helper.alarm_hidden_members_count(alarm)).to eq(1)
      end
    end
  end
end