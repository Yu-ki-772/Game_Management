# spec/requests/users/registrations_spec.rb
require "rails_helper"

RSpec.describe "Users::Registrations", type: :request do
  describe "新規登録" do
    context "有効なパラメータのとき" do
      let(:registration_params) do
        {
          user: {
            name:                  "テストユーザー",
            email:                 "test@example.com",
            password:              "Password123!",
            password_confirmation: "Password123!"
          }
        }
      end

      it "ユーザーが1件作成される" do
        expect { post user_registration_path, params: registration_params }
          .to change { User.count }.by(1)
      end

      it "root_pathにリダイレクトする" do
        post user_registration_path, params: registration_params
        expect(response).to redirect_to(root_path)
      end

      it "nameが保存される" do
        post user_registration_path, params: registration_params
        expect(User.last.name).to eq("テストユーザー")
      end
    end

    context "無効なパラメータのとき（メールアドレスが重複している）" do
      let!(:existing_user) { create(:user, email: "duplicate@example.com") }

      let(:duplicate_email_params) do
        {
          user: {
            name:                  "別のユーザー",
            email:                 "duplicate@example.com",
            password:              "Password123!",
            password_confirmation: "Password123!"
          }
        }
      end

      it "ユーザーが作成されない" do
        expect { post user_registration_path, params: duplicate_email_params }
          .not_to change { User.count }
      end

      it "422を返す" do
        post user_registration_path, params: duplicate_email_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "プロフィール更新" do
    let(:user) { create(:user) }
    before { sign_in user }

    context "有効なパラメータのとき" do
      let(:update_params) do
        {
          user: {
            name:             "新しい名前",
            current_password: "Password123!"
          }
        }
      end

      it "user_pathにリダイレクトする" do
        patch user_registration_path, params: update_params
        expect(response).to redirect_to(user_path(id: user.uuid))
      end
    end

    context "無効なパラメータのとき（nameが空）" do
      let(:blank_name_params) do
        {
          user: {
            name:             "",
            current_password: "Password123!"
          }
        }
      end

      it "422を返す" do
        patch user_registration_path, params: blank_name_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
