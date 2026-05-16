# spec/jobs/alarm_notification_job_spec.rb
require "rails_helper"

RSpec.describe AlarmNotificationJob do
  let(:user)  { create(:user) }
  let(:alarm) { create(:alarm, creator: user, user_uuid: user.uuid, scheduled_at: 30.minutes.from_now) }

  # 異常系
  describe "アラームが存在しないとき" do
    it "AlarmMemberNotificationJobをエンキューしない" do
      expect {
        described_class.perform_now("存在しないuuid")
      }.not_to have_enqueued_job(AlarmMemberNotificationJob)
    end
  end

  # 異常系
  describe "既に送信済みのとき（sent: true）" do
    before { alarm.update_column(:sent, true) }

    it "AlarmMemberNotificationJobをエンキューしない" do
      expect {
        described_class.perform_now(alarm.uuid)
      }.not_to have_enqueued_job(AlarmMemberNotificationJob)
    end
  end

  # 異常系
  describe "未通知のメンバーが存在しないとき" do
    before do
      create(:alarm_log, alarm_uuid: alarm.uuid, user_uuid: user.uuid)
    end

    it "AlarmMemberNotificationJobをエンキューしない" do
      expect {
        described_class.perform_now(alarm.uuid)
      }.not_to have_enqueued_job(AlarmMemberNotificationJob)
    end

    it "sentがtrueに更新されない" do
      described_class.perform_now(alarm.uuid)
      expect(alarm.reload.sent).to be false
    end
  end

  # 正常系
  describe "未通知のメンバーが存在するとき" do
    it "未通知のメンバー分だけAlarmMemberNotificationJobをエンキューする" do
      expect {
        described_class.perform_now(alarm.uuid)
      }.to have_enqueued_job(AlarmMemberNotificationJob).with(alarm.uuid, user.uuid)
    end

    it "sentをtrueに更新する" do
      described_class.perform_now(alarm.uuid)
      expect(alarm.reload.sent).to be true
    end
  end
end
