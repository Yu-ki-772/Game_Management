# spec/jobs/alarm_reminder_job_spec.rb
require "rails_helper"

RSpec.describe AlarmReminderJob, type: :job do
  let(:user)  { create(:user) }
  let(:alarm) { create(:alarm, creator: user, user_uuid: user.uuid, scheduled_at: 30.minutes.from_now) }

  # 異常系
  describe "アラームが存在しないとき" do
    it "AlarmMemberReminderJobをエンキューしない" do
      expect {
        described_class.perform_now("存在しないuuid")
      }.not_to have_enqueued_job(AlarmMemberReminderJob)
    end
  end

  # 異常系
  describe "未通知のメンバーが存在しない（全員ストップ済み）とき" do
    before do
      create(:alarm_log, alarm: alarm, user_uuid: user.uuid)
    end

    it "AlarmMemberReminderJobをエンキューしない" do
      expect {
        described_class.perform_now(alarm.uuid)
      }.not_to have_enqueued_job(AlarmMemberReminderJob)
    end
  end

  # 正常系
  describe "未通知のメンバーが存在するとき" do
    it "未通知のメンバー分だけAlarmMemberReminderJobをエンキューする" do
      expect {
        described_class.perform_now(alarm.uuid)
      }.to have_enqueued_job(AlarmMemberReminderJob).with(alarm.uuid, user.uuid, 30)
    end
  end
end