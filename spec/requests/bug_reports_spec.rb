# spec/requests/bug_reports_spec.rb
require "rails_helper"

RSpec.describe "BugReports" do
  let(:user) { create(:user) }

  describe "未ログインのとき" do
    it "new はログイン画面にリダイレクトする" do
      get new_bug_report_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "create はログイン画面にリダイレクトする" do
      post bug_report_path, params: { body: "不具合内容" }
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "new" do
    before { sign_in user }

    it "200を返す" do
      get new_bug_report_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "create" do
    before { sign_in user }

    context "有効なパラメータのとき" do
      it "others_pathにリダイレクトする" do
        post bug_report_path, params: { body: "不具合内容" }
        expect(response).to redirect_to(others_path)
      end
    end

    context "bodyが空のとき" do
      it "422を返す" do
        post bug_report_path, params: { body: "" }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "bodyが1000文字を超えるとき" do
      it "422を返す" do
        post bug_report_path, params: { body: "a" * 1001 }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
