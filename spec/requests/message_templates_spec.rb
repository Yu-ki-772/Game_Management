# spec/requests/message_templates_spec.rb
require "rails_helper"

RSpec.describe "MessageTemplates" do
  let(:user) { create(:user) }

  describe "未ログインのとき" do
    it "index はログイン画面にリダイレクトする" do
      get message_templates_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "bookmarks はログイン画面にリダイレクトする" do
      get bookmarks_message_templates_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "manage はログイン画面にリダイレクトする" do
      get manage_message_templates_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "new はログイン画面にリダイレクトする" do
      get new_message_template_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "create はログイン画面にリダイレクトする" do
      post message_templates_path, params: { message_template: { reason: "理由", template: "テンプレート" } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "edit はログイン画面にリダイレクトする" do
      template = create(:message_template, user: user)
      get edit_message_template_path(template)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "update はログイン画面にリダイレクトする" do
      template = create(:message_template, user: user)
      patch message_template_path(template), params: { message_template: { reason: "更新後" } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "destroy はログイン画面にリダイレクトする" do
      template = create(:message_template, user: user)
      delete message_template_path(template)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "index" do
    before { sign_in user }

    it "200を返す" do
      get message_templates_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "bookmarks" do
    before { sign_in user }

    it "200を返す" do
      get bookmarks_message_templates_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "manage" do
    before { sign_in user }

    it "200を返す" do
      get manage_message_templates_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "new" do
    before { sign_in user }

    it "200を返す" do
      get new_message_template_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "create" do
    before { sign_in user }

    context "有効なパラメータのとき" do
      let(:valid_params) do
        { message_template: { reason: "理由", template: "テンプレート" } }
      end

      it "message_templates_pathにリダイレクトする" do
        post message_templates_path, params: valid_params
        expect(response).to redirect_to(message_templates_path)
      end

      it "MessageTemplateが1件作成される" do
        expect {
          post message_templates_path, params: valid_params
        }.to change(MessageTemplate, :count).by(1)
      end
    end

    context "無効なパラメータのとき（reasonが空）" do
      let(:invalid_params) do
        { message_template: { reason: "", template: "テンプレート" } }
      end

      it "422を返す" do
        post message_templates_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "edit" do
    before { sign_in user }

    context "自分のテンプレートのとき" do
      let(:template) { create(:message_template, user: user) }

      it "200を返す" do
        get edit_message_template_path(template)
        expect(response).to have_http_status(:ok)
      end
    end

    context "他のユーザーのテンプレートのとき" do
      let(:other_user)     { create(:user) }
      let(:other_template) { create(:message_template, user: other_user) }

      it "404を返す" do
        get edit_message_template_path(other_template)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "共通テンプレートに対して操作しようとするとき" do
      let!(:common_template) { create(:message_template, :common) }

      it "404を返す" do
        get edit_message_template_path(common_template)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "update" do
    before { sign_in user }

    context "自分のテンプレートのとき" do
      let(:template) { create(:message_template, user: user) }

      context "有効なパラメータのとき" do
        it "message_templates_pathにリダイレクトする" do
          patch message_template_path(template), params: { message_template: { reason: "更新後の理由" } }
          expect(response).to redirect_to(message_templates_path)
        end

        it "reasonが更新される" do
          patch message_template_path(template), params: { message_template: { reason: "更新後の理由" } }
          expect(template.reload.reason).to eq("更新後の理由")
        end
      end

      context "無効なパラメータのとき（reasonが空）" do
        it "422を返す" do
          patch message_template_path(template), params: { message_template: { reason: "" } }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "他のユーザーのテンプレートのとき" do
      let(:other_user)     { create(:user) }
      let(:other_template) { create(:message_template, user: other_user) }

      it "404を返す" do
        patch message_template_path(other_template), params: { message_template: { reason: "不正アクセス" } }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "共通テンプレートに対して操作しようとするとき" do
      let!(:common_template) { create(:message_template, :common) }

      it "404を返す" do
        patch message_template_path(common_template), params: { message_template: { reason: "不正アクセス" } }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "destroy" do
    before { sign_in user }

    context "自分のテンプレートのとき" do
      let!(:template) { create(:message_template, user: user) }

      it "manage_message_templates_pathにリダイレクトする" do
        delete message_template_path(template)
        expect(response).to redirect_to(manage_message_templates_path)
      end

      it "MessageTemplateが削除される" do
        expect {
          delete message_template_path(template)
        }.to change(MessageTemplate, :count).by(-1)
      end
    end

    context "他のユーザーのテンプレートのとき" do
      let(:other_user)      { create(:user) }
      let!(:other_template) { create(:message_template, user: other_user) }

      it "MessageTemplateが削除されない" do
        expect {
          delete message_template_path(other_template)
        }.not_to change(MessageTemplate, :count)
      end
    end

    context "共通テンプレートに対して操作しようとするとき" do
      let!(:common_template) { create(:message_template, :common) }

      it "MessageTemplateが削除されない" do
        expect {
          delete message_template_path(common_template)
        }.not_to change(MessageTemplate, :count)
      end
    end
  end
end