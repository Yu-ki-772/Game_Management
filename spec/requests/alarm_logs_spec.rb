# spec/requests/alarm_logs_spec.rb
require "rails_helper"

RSpec.describe "AlarmLogs" do
  let(:user)  { create(:user) }
  let(:alarm) { create(:alarm, creator: user, user_uuid: user.uuid) }

  describe "未ログインのとき" do
    it "statistic はログイン画面にリダイレクトする" do
      get statistic_alarm_logs_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "index はログイン画面にリダイレクトする" do
      get alarm_logs_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "statistic" do
    before { sign_in user }

    context "アラームログが存在しないとき" do
      it "200を返す" do
        get statistic_alarm_logs_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "アラームログが存在するとき" do
      before { create(:alarm_log, alarm: alarm, user_uuid: user.uuid) }

      it "200を返す" do
        get statistic_alarm_logs_path
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "index" do
    before { sign_in user }

    context "アラームログが存在しないとき" do
      it "200を返す" do
        get alarm_logs_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "アラームログが存在するとき" do
      before { create(:alarm_log, alarm: alarm, user_uuid: user.uuid) }

      it "200を返す" do
        get alarm_logs_path
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
