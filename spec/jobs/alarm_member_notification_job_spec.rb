# spec/jobs/alarm_member_notification_job_spec.rb
require "rails_helper"

RSpec.describe AlarmMemberNotificationJob, type: :job do
  before do
    allow(WebPush).to receive(:payload_send)
  end

  let(:user)       { create(:user) }
  let(:alarm)      { create(:alarm, creator: user, user_uuid: user.uuid, scheduled_at: 30.minutes.from_now) }
  let(:membership) { alarm.alarm_memberships.find_by(user_uuid: user.uuid) }

  # 正常系
  describe "全ての条件を満たすとき" do
    before do
      create(:web_push_subscription, user: user)
    end

    it "push通知を送信する" do
      expect(WebPush).to receive(:payload_send).at_least(:once)
      described_class.perform_now(alarm.uuid, user.uuid)
    end

    it "membershipのnotifiedをtrueに更新する" do
      described_class.perform_now(alarm.uuid, user.uuid)
      expect(membership.reload.notified).to be true
    end
  end

  # 異常系
  describe "アラームが存在しないとき" do
    it "push通知を送信しない" do
      expect(WebPush).not_to receive(:payload_send)
      described_class.perform_now("存在しないuuid", user.uuid)
    end
  end

  # 異常系
  describe "既にストップ済みのとき" do
    before do
      create(:web_push_subscription, user: user)
      create(:alarm_log, alarm: alarm, user_uuid: user.uuid)
    end

    it "push通知を送信しない" do
      expect(WebPush).not_to receive(:payload_send)
      described_class.perform_now(alarm.uuid, user.uuid)
    end
  end

  # 異常系
  describe "メンバーシップが存在しないとき" do
    before do
      create(:web_push_subscription, user: user)
      alarm.alarm_memberships.destroy_all
    end

    it "push通知を送信しない" do
      expect(WebPush).not_to receive(:payload_send)
      described_class.perform_now(alarm.uuid, user.uuid)
    end
  end

  # 異常系
  describe "既に通知済みのとき（notified: true）" do
    before do
      create(:web_push_subscription, user: user)
      membership.update!(notified: true)
    end

    it "push通知を送信しない" do
      expect(WebPush).not_to receive(:payload_send)
      described_class.perform_now(alarm.uuid, user.uuid)
    end
  end

  # 異常系
  describe "ユーザーが存在しないとき" do
    before do
      allow(User).to receive(:find_by).and_return(nil)
    end

    it "push通知を送信しない" do
      expect(WebPush).not_to receive(:payload_send)
      described_class.perform_now(alarm.uuid, user.uuid)
    end

    it "notified が true にならない" do
      described_class.perform_now(alarm.uuid, user.uuid)
      expect(membership.reload.notified).to be false
    end
  end

  # 異常系
  describe "WebPush::ExpiredSubscription が発生したとき" do
    before do
      create(:web_push_subscription, user: user)
      response_double = double("response", body: "", code: "410")
      allow(WebPush).to receive(:payload_send).and_raise(WebPush::ExpiredSubscription.new(response_double, "host"))
    end

    it "該当の購読が削除される" do
      expect {
        described_class.perform_now(alarm.uuid, user.uuid)
      }.to change(WebPushSubscription, :count).by(-1)
    end
  end

  # 異常系
  describe "WebPush::ResponseError が発生したとき" do
    before do
      create(:web_push_subscription, user: user)
      response_double = double("response", body: "")
      allow(WebPush).to receive(:payload_send).and_raise(WebPush::ResponseError.new(response_double, "host"))
    end

    it "ジョブが継続してエラーにならない" do
      expect {
        described_class.perform_now(alarm.uuid, user.uuid)
      }.not_to raise_error
    end

    it "エラーログを出力する" do
      expect(Rails.logger).to receive(:error).at_least(:once)
      described_class.perform_now(alarm.uuid, user.uuid)
    end
  end
end