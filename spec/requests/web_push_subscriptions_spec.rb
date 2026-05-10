# spec/requests/web_push_subscriptions_spec.rb
require "rails_helper"

RSpec.describe "WebPushSubscriptions", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  # =========================================================
  # DELETE /web_push_subscriptions (destroy)
  # =========================================================
  describe "DELETE /web_push_subscriptions" do
    context "購読が存在するとき" do
      let!(:subscription) { create(:web_push_subscription, user: user) }

      it "200を返す" do
        delete web_push_subscriptions_path,
          params: { endpoint: subscription.endpoint },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response).to have_http_status(:ok)
      end

      it "購読が削除される" do
        expect {
          delete web_push_subscriptions_path,
            params: { endpoint: subscription.endpoint },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
        }.to change(WebPushSubscription, :count).by(-1)
      end
    end

    context "購読が存在しないとき" do
      it "200を返す" do
        delete web_push_subscriptions_path,
          params: { endpoint: "存在しないendpoint" },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
