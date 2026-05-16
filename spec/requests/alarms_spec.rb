# spec/requests/alarms_spec.rb
require "rails_helper"

RSpec.describe "Alarms" do
  let(:user) { create(:user) }

  describe "未ログインのとき" do
    it "index はログイン画面にリダイレクトする" do
      get alarms_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "new はログイン画面にリダイレクトする" do
      get new_alarm_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "calendar はログイン画面にリダイレクトする" do
      get calendar_alarms_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "pending はログイン画面にリダイレクトする" do
      get pending_alarms_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "create はログイン画面にリダイレクトする" do
      post alarms_path, params: { alarm: { label: "テスト", scheduled_at: 1.hour.from_now } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "edit はログイン画面にリダイレクトする" do
      alarm = create(:alarm, creator: user, user_uuid: user.uuid)
      get edit_alarm_path(alarm)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "update はログイン画面にリダイレクトする" do
      alarm = create(:alarm, creator: user, user_uuid: user.uuid)
      patch alarm_path(alarm), params: { alarm: { label: "変更後" } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "destroy はログイン画面にリダイレクトする" do
      alarm = create(:alarm, creator: user, user_uuid: user.uuid)
      delete alarm_path(alarm)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "index" do
    before { sign_in user }

    it "200を返す" do
      get alarms_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "calendar" do
    before { sign_in user }

    it "200を返す" do
      get calendar_alarms_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "pending" do
    before { sign_in user }

    it "200を返す" do
      get pending_alarms_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "new" do
    before { sign_in user }

    it "200を返す" do
      get new_alarm_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "create" do
    before { sign_in user }

    context "有効なパラメータのとき" do
      let(:create_params) do
        scheduled = 2.hours.from_now
        {
          alarm: {
            label:        "起床アラーム",
            scheduled_at: scheduled,
            started_at:   scheduled - 1.hour
          }
        }
      end

      it "alarms_pathにリダイレクトする" do
        post alarms_path, params: create_params
        expect(response).to redirect_to(alarms_path)
      end
    end

    context "無効なパラメータのとき（labelが空）" do
      let(:invalid_params) do
        { alarm: { label: "", scheduled_at: 1.hour.from_now } }
      end

      it "422を返す" do
        post alarms_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "edit" do
    before { sign_in user }

    context "自分のアラームのとき" do
      let(:alarm) { create(:alarm, creator: user, user_uuid: user.uuid) }

      it "200を返す" do
        get edit_alarm_path(alarm)
        expect(response).to have_http_status(:ok)
      end
    end

    context "他のユーザーのアラームのとき" do
      let(:other_user)  { create(:user) }
      let(:other_alarm) { create(:alarm, creator: other_user, user_uuid: other_user.uuid) }

      it "404を返す" do
        get edit_alarm_path(other_alarm)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "update" do
    before { sign_in user }

    context "自分のアラームのとき" do
      let(:alarm) { create(:alarm, creator: user, user_uuid: user.uuid) }

      context "有効なパラメータのとき" do
        it "alarms_pathにリダイレクトする" do
          patch alarm_path(alarm), params: { alarm: { label: "更新後のラベル" } }
          expect(response).to redirect_to(alarms_path)
        end
      end

      context "無効なパラメータのとき（labelが空）" do
        it "422を返す" do
          patch alarm_path(alarm), params: { alarm: { label: "" } }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "他のユーザーのアラームのとき" do
      let(:other_user)  { create(:user) }
      let(:other_alarm) { create(:alarm, creator: other_user, user_uuid: other_user.uuid) }

      it "404を返す" do
        patch alarm_path(other_alarm), params: { alarm: { label: "不正アクセス" } }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "destroy" do
    before { sign_in user }

    context "自分のアラームのとき" do
      let!(:alarm) { create(:alarm, creator: user, user_uuid: user.uuid) }

      it "alarms_pathにリダイレクトする" do
        delete alarm_path(alarm)
        expect(response).to redirect_to(alarms_path)
      end
    end

    context "他のユーザーのアラームのとき" do
      let(:other_user)   { create(:user) }
      let!(:other_alarm) { create(:alarm, creator: other_user, user_uuid: other_user.uuid) }

      it "404を返す" do
        delete alarm_path(other_alarm)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
