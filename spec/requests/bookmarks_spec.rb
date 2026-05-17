# spec/requests/bookmarks_spec.rb
require "rails_helper"

RSpec.describe "Bookmarks" do
  let(:user)             { create(:user) }
  let(:message_template) { create(:message_template) }

  describe "未ログインのとき" do
    it "create はログイン画面にリダイレクトする" do
      post bookmarks_path, params: { message_template_id: message_template.id }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "destroy はログイン画面にリダイレクトする" do
      bookmark = create(:bookmark, user: user, message_template: message_template)
      delete bookmark_path(bookmark)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "create" do
    before { sign_in user }

    it "ブックマークが1件作成される" do
      expect {
        post bookmarks_path, params: { message_template_id: message_template.id }
      }.to change(Bookmark, :count).by(1)
    end

    it "自分のブックマークとして作成される" do
      post bookmarks_path, params: { message_template_id: message_template.id }
      expect(Bookmark.last.user_uuid).to eq(user.uuid)
    end
  end

  describe "destroy" do
    before { sign_in user }

    context "自分のブックマークのとき" do
      let!(:bookmark) { create(:bookmark, user: user, message_template: message_template) }

      it "ブックマークが削除される" do
        expect {
          delete bookmark_path(bookmark)
        }.to change(Bookmark, :count).by(-1)
      end
    end

    context "他のユーザーのブックマークのとき" do
      let(:other_user)      { create(:user) }
      let!(:other_bookmark) { create(:bookmark, user: other_user, message_template: message_template) }

      it "404を返す" do
        delete bookmark_path(other_bookmark)
        expect(response).to have_http_status(:not_found)
      end

      it "ブックマークが削除されない" do
        expect {
          delete bookmark_path(other_bookmark)
        }.not_to change(Bookmark, :count)
      end
    end
  end
end