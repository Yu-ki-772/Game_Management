# spec/jobs/alarm_member_reminder_job_spec.rb
require "rails_helper"

RSpec.describe AlarmMemberReminderJob, type: :job do
  before do
    allow(WebPush).to receive(:payload_send)
  end

  let(:user)                { create(:user) }
  let(:alarm)               { create(:alarm, creator: user, user_uuid: user.uuid, scheduled_at: 30.minutes.from_now) }
  let(:membership)          { alarm.alarm_memberships.find_by(user_uuid: user.uuid) }
  let(:minutes_until_alarm) { 30 }

  # =========================================================
  # 正常系: 全ての条件を満たすとき
  # =========================================================
  describe "全ての条件を満たすとき" do
    before do
      create(:web_push_subscription, user: user)
    end

    it "push通知を送信する" do
      expect(WebPush).to receive(:payload_send).at_least(:once)
      described_class.perform_now(alarm.uuid, user.uuid, minutes_until_alarm)
    end

    it "membershipのreminder_notifiedをtrueに更新する" do
      described_class.perform_now(alarm.uuid, user.uuid, minutes_until_alarm)
      expect(membership.reload.reminder_notified).to be true
    end
  end

  # =========================================================
  # ガード節: アラームが存在しないとき
  # =========================================================
  describe "アラームが存在しないとき" do
    it "push通知を送信しない" do
      expect(WebPush).not_to receive(:payload_send)
      described_class.perform_now("存在しないuuid", user.uuid, minutes_until_alarm)
    end
  end

  # =========================================================
  # ガード節: 既にストップ済みのとき
  # =========================================================
  describe "既にストップ済みのとき" do
    before do
      create(:web_push_subscription, user: user)
      create(:alarm_log, alarm: alarm, user_uuid: user.uuid)
    end

    it "push通知を送信しない" do
      expect(WebPush).not_to receive(:payload_send)
      described_class.perform_now(alarm.uuid, user.uuid, minutes_until_alarm)
    end
  end

  # =========================================================
  # ガード節: メンバーシップが存在しないとき
  # =========================================================
  describe "メンバーシップが存在しないとき" do
    before do
      create(:web_push_subscription, user: user)
      alarm.alarm_memberships.destroy_all
    end

    it "push通知を送信しない" do
      expect(WebPush).not_to receive(:payload_send)
      described_class.perform_now(alarm.uuid, user.uuid, minutes_until_alarm)
    end
  end

  # =========================================================
  # ガード節: 既にリマインダー通知済みのとき
  # =========================================================
  describe "既にリマインダー通知済みのとき（reminder_notified: true）" do
    before do
      create(:web_push_subscription, user: user)
      membership.update!(reminder_notified: true)
    end

    it "push通知を送信しない" do
      expect(WebPush).not_to receive(:payload_send)
      described_class.perform_now(alarm.uuid, user.uuid, minutes_until_alarm)
    end
  end

  # =========================================================
  # ガード節: ユーザーが存在しないとき
  # =========================================================
  describe "ユーザーが存在しないとき" do
    before do
      allow(User).to receive(:find_by).and_return(nil)
    end

    it "push通知を送信しない" do
      expect(WebPush).not_to receive(:payload_send)
      described_class.perform_now(alarm.uuid, user.uuid, minutes_until_alarm)
    end

    it "reminder_notified が true にならない" do
      described_class.perform_now(alarm.uuid, user.uuid, minutes_until_alarm)
      expect(membership.reload.reminder_notified).to be false
    end
  end
end
