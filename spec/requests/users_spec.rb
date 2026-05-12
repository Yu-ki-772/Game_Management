# spec/requests/users_spec.rb
require "rails_helper"

RSpec.describe "Users", type: :request do
  let(:user) { create(:user) }

  describe "未ログインのとき" do
    it "index はログイン画面にリダイレクトする" do
      get users_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "show はログイン画面にリダイレクトする" do
      get user_path(user)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "index" do
    before { sign_in user }

    context "検索クエリがないとき" do
      it "200を返す" do
        get users_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "検索クエリがあるとき" do
      let!(:target_user) { create(:user, name: "検索対象ユーザー") }

      it "200を返す" do
        get users_path, params: { q: { name_cont: "検索対象" } }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "show" do
    before { sign_in user }

    context "自分のプロフィールを見るとき" do
      it "200を返す" do
        get user_path(user)
        expect(response).to have_http_status(:ok)
      end
    end

    context "他のユーザーのプロフィールを見るとき" do
      let(:other_user) { create(:user) }

      it "200を返す" do
        get user_path(other_user)
        expect(response).to have_http_status(:ok)
      end
    end

    context "管理者ユーザーにアクセスしようとするとき" do
      let(:admin_user) { create(:user, :admin) }

      it "404を返す" do
        get user_path(admin_user)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "存在しないユーザーにアクセスしようとするとき" do
      it "404を返す" do
        get user_path("non_existent_uuid")
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
