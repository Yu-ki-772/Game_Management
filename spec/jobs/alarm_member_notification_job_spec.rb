# spec/jobs/alarm_member_notification_job_spec.rb
require "rails_helper"

RSpec.describe AlarmMemberNotificationJob do
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
      described_class.perform_now(alarm.uuid, user.uuid)
      expect(WebPush).to have_received(:payload_send).at_least(:once)
    end

    it "membershipのnotifiedをtrueに更新する" do
      described_class.perform_now(alarm.uuid, user.uuid)
      expect(membership.reload.notified).to be true
    end
  end

  # 異常系
  describe "アラームが存在しないとき" do
    it "push通知を送信しない" do
      described_class.perform_now("存在しないuuid", user.uuid)
      expect(WebPush).not_to have_received(:payload_send)
    end
  end

  # 異常系
  describe "既にストップ済みのとき" do
    before do
      create(:web_push_subscription, user: user)
      create(:alarm_log, alarm: alarm, user_uuid: user.uuid)
    end

    it "push通知を送信しない" do
      described_class.perform_now(alarm.uuid, user.uuid)
      expect(WebPush).not_to have_received(:payload_send)
    end
  end

  # 異常系
  describe "メンバーシップが存在しないとき" do
    before do
      create(:web_push_subscription, user: user)
      alarm.alarm_memberships.destroy_all
    end

    it "push通知を送信しない" do
      described_class.perform_now(alarm.uuid, user.uuid)
      expect(WebPush).not_to have_received(:payload_send)
    end
  end

  # 異常系
  describe "既に通知済みのとき（notified: true）" do
    before do
      create(:web_push_subscription, user: user)
      membership.update!(notified: true)
    end

    it "push通知を送信しない" do
      described_class.perform_now(alarm.uuid, user.uuid)
      expect(WebPush).not_to have_received(:payload_send)
    end
  end

  # 異常系
  describe "ユーザーが存在しないとき" do
    before do
      allow(User).to receive(:find_by).and_return(nil)
    end

    it "push通知を送信しない" do
      described_class.perform_now(alarm.uuid, user.uuid)
      expect(WebPush).not_to have_received(:payload_send)
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
      # rubocop:disable RSpec/VerifiedDoubles
      response_double = double("response", body: "", code: "410")
      # rubocop:enable RSpec/VerifiedDoubles
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
      # rubocop:disable RSpec/VerifiedDoubles
      response_double = double("response", body: "")
      # rubocop:enable RSpec/VerifiedDoubles
      allow(WebPush).to receive(:payload_send).and_raise(WebPush::ResponseError.new(response_double, "host"))
    end

    it "ジョブが継続してエラーにならない" do
      expect {
        described_class.perform_now(alarm.uuid, user.uuid)
      }.not_to raise_error
    end

    it "エラーログを出力する" do
      allow(Rails.logger).to receive(:error)
      described_class.perform_now(alarm.uuid, user.uuid)
      expect(Rails.logger).to have_received(:error).at_least(:once)
    end
  end
end
