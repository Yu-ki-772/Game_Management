# spec/requests/web_push_subscriptions_spec.rb
require "rails_helper"

RSpec.describe "WebPushSubscriptions" do
  let(:user) { create(:user) }

  describe "未ログインのとき" do
    it "create はログイン画面にリダイレクトする" do
      post web_push_subscriptions_path,
        params: { endpoint: "endpoint", p256dh: "p256dh", auth: "auth" },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "destroy はログイン画面にリダイレクトする" do
      delete web_push_subscriptions_path,
        params: { endpoint: "endpoint" },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "create" do
    before { sign_in user }

    it "購読が作成される" do
      expect {
        post web_push_subscriptions_path,
          params: { endpoint: "https://example.com/push/endpoint", p256dh: "p256dh", auth: "auth" },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(WebPushSubscription, :count).by(1)
      expect(response).to have_http_status(:ok)
    end

    context "同一ユーザーが同一endpointで再購読するとき" do
      let!(:subscription) { create(:web_push_subscription, user: user, p256dh: "old_p256dh", auth: "old_auth") }

      it "購読が増えない" do
        expect {
          post web_push_subscriptions_path,
            params: { endpoint: subscription.endpoint, p256dh: "new_p256dh", auth: "new_auth" },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
        }.not_to change(WebPushSubscription, :count)
      end

      it "p256dhとauthが更新される" do
        post web_push_subscriptions_path,
          params: { endpoint: subscription.endpoint, p256dh: "new_p256dh", auth: "new_auth" },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
        subscription.reload
        expect(subscription.p256dh).to eq("new_p256dh")
        expect(subscription.auth).to eq("new_auth")
      end
    end
  end

  describe "destroy" do
    before { sign_in user }

    context "購読が存在するとき" do
      let!(:subscription) { create(:web_push_subscription, user: user) }

      it "購読が削除される" do
        expect {
          delete web_push_subscriptions_path,
            params: { endpoint: subscription.endpoint },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
        }.to change(WebPushSubscription, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context "購読が存在しないとき" do
      it "204を返す" do
        delete web_push_subscriptions_path,
          params: { endpoint: "存在しないendpoint" },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response).to have_http_status(:no_content)
      end
    end

    context "他のユーザーの購読のとき" do
      let(:other_user) { create(:user) }
      let!(:other_subscription) { create(:web_push_subscription, user: other_user) }

      it "購読が削除されない" do
        expect {
          delete web_push_subscriptions_path,
            params: { endpoint: other_subscription.endpoint },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
        }.not_to change(WebPushSubscription, :count)
      end
    end
  end
end
