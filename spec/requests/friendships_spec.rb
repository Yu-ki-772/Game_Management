# spec/requests/friendships_spec.rb
require "rails_helper"

RSpec.describe "Friendships" do
  let(:user)       { create(:user) }
  let(:other_user) { create(:user) }

  describe "未ログインのとき" do
    it "pending はログイン画面にリダイレクトする" do
      get pending_friendships_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "index はログイン画面にリダイレクトする" do
      get friendships_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "create はログイン画面にリダイレクトする" do
      post friendships_path, params: { friend_uuid: other_user.uuid }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "update はログイン画面にリダイレクトする" do
      friendship = create(:friendship, user: other_user, friend: user)
      patch friendship_path(friendship), params: { action_type: "accept" }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "destroy はログイン画面にリダイレクトする" do
      friendship = create(:friendship, user: user, friend: other_user)
      delete friendship_path(friendship)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "pending" do
    before { sign_in user }

    it "200を返す" do
      get pending_friendships_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "index" do
    before { sign_in user }

    it "200を返す" do
      get friendships_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "create" do
    before { sign_in user }

    context "フレンド申請が成功するとき" do
      it "users_pathにリダイレクトする" do
        post friendships_path, params: { friend_uuid: other_user.uuid }
        expect(response).to redirect_to(users_path)
      end

      it "Friendshipが1件作成される" do
        expect {
          post friendships_path, params: { friend_uuid: other_user.uuid }
        }.to change(Friendship, :count).by(1)
      end
    end
  end

  describe "update" do
    before { sign_in user }

    context "自分宛のフレンド申請のとき" do
      let!(:friendship) { create(:friendship, user: other_user, friend: user) }

      context "承認するとき" do
        it "pending_friendships_pathにリダイレクトする" do
          patch friendship_path(friendship), params: { action_type: "accept" }
          expect(response).to redirect_to(pending_friendships_path)
        end

        it "ステータスがacceptedになる" do
          patch friendship_path(friendship), params: { action_type: "accept" }
          expect(friendship.reload.status).to eq("accepted")
        end
      end

      context "拒否するとき" do
        it "pending_friendships_pathにリダイレクトする" do
          patch friendship_path(friendship), params: { action_type: "reject" }
          expect(response).to redirect_to(pending_friendships_path)
        end

        it "Friendshipが削除される" do
          expect {
            patch friendship_path(friendship), params: { action_type: "reject" }
          }.to change(Friendship, :count).by(-1)
        end
      end
    end

    context "自分宛でないフレンド申請のとき" do
      let(:third_user)  { create(:user) }
      let!(:friendship) { create(:friendship, user: other_user, friend: third_user) }

      it "friendships_pathにリダイレクトする" do
        patch friendship_path(friendship), params: { action_type: "accept" }
        expect(response).to redirect_to(friendships_path)
      end
    end
  end

  describe "destroy" do
    before { sign_in user }

    context "自分のフレンド関係のとき" do
      let!(:friendship) { create(:friendship, user: user, friend: other_user, status: :accepted) }

      it "friendships_pathにリダイレクトする" do
        delete friendship_path(friendship)
        expect(response).to redirect_to(friendships_path)
      end

      it "フレンド関係が削除される" do
        expect {
          delete friendship_path(friendship)
        }.to change(Friendship, :count).by(-1)
      end
    end

    context "自分と無関係なフレンド関係のとき" do
      let(:third_user)  { create(:user) }
      let!(:friendship) { create(:friendship, user: other_user, friend: third_user, status: :accepted) }

      it "フレンド関係が削除されない" do
        expect {
          delete friendship_path(friendship)
        }.not_to change(Friendship, :count)
      end
    end
  end
end