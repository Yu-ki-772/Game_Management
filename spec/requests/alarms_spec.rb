# spec/requests/alarms_spec.rb
require "rails_helper"

RSpec.describe "Alarms", type: :request do
  let(:user) { create(:user) }

  # =========================================================
  # 未ログインのとき
  # =========================================================
  describe "未ログインのとき" do
    it "GET /alarms はログイン画面にリダイレクトする" do
      get alarms_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "GET /alarms/new はログイン画面にリダイレクトする" do
      get new_alarm_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "GET /alarms/calendar はログイン画面にリダイレクトする" do
      get calendar_alarms_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "GET /alarms/pending はログイン画面にリダイレクトする" do
      get pending_alarms_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "POST /alarms はログイン画面にリダイレクトする" do
      post alarms_path, params: { alarm: { label: "テスト", scheduled_at: 1.hour.from_now } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "GET /alarms/:id/edit はログイン画面にリダイレクトする" do
      alarm = create(:alarm, creator: user, user_uuid: user.uuid)
      get edit_alarm_path(alarm)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "PATCH /alarms/:id はログイン画面にリダイレクトする" do
      alarm = create(:alarm, creator: user, user_uuid: user.uuid)
      patch alarm_path(alarm), params: { alarm: { label: "変更後" } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "PATCH /alarms/:id/stop はログイン画面にリダイレクトする" do
      alarm = create(:alarm, creator: user, user_uuid: user.uuid)
      patch stop_alarm_path(alarm)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "DELETE /alarms/:id はログイン画面にリダイレクトする" do
      alarm = create(:alarm, creator: user, user_uuid: user.uuid)
      delete alarm_path(alarm)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  # =========================================================
  # GET /alarms (index)
  # =========================================================
  describe "GET /alarms" do
    before { sign_in user }

    it "200を返す" do
      get alarms_path
      expect(response).to have_http_status(:ok)
    end
  end

  # =========================================================
  # GET /alarms/calendar (calendar)
  # =========================================================
  describe "GET /alarms/calendar" do
    before { sign_in user }

    it "200を返す" do
      get calendar_alarms_path
      expect(response).to have_http_status(:ok)
    end
  end

  # =========================================================
  # GET /alarms/pending (pending)
  # =========================================================
  describe "GET /alarms/pending" do
    before { sign_in user }

    it "200を返す" do
      get pending_alarms_path
      expect(response).to have_http_status(:ok)
    end
  end

  # =========================================================
  # GET /alarms/new (new)
  # =========================================================
  describe "GET /alarms/new" do
    before { sign_in user }

    it "200を返す" do
      get new_alarm_path
      expect(response).to have_http_status(:ok)
    end
  end

  # =========================================================
  # POST /alarms (create)
  # =========================================================
  describe "POST /alarms" do
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

  # =========================================================
  # GET /alarms/:id/edit (edit)
  # =========================================================
  describe "GET /alarms/:id/edit" do
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

  # =========================================================
  # PATCH /alarms/:id (update)
  # =========================================================
  describe "PATCH /alarms/:id" do
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

  # =========================================================
  # PATCH /alarms/:id/stop (stop)
  # =========================================================
  describe "PATCH /alarms/:id/stop" do
    before { sign_in user }

    context "メンバーシップが存在するとき" do
      let(:alarm) do
        create(:alarm, creator: user, user_uuid: user.uuid, scheduled_at: 30.minutes.from_now)
      end

      it "statistic_alarm_logs_pathにリダイレクトする" do
        patch stop_alarm_path(alarm)
        expect(response).to redirect_to(statistic_alarm_logs_path)
      end
    end

    context "メンバーシップが存在しないとき" do
      let(:alarm) do
        alarm = create(:alarm, creator: user, user_uuid: user.uuid, scheduled_at: 30.minutes.from_now)

        alarm.alarm_memberships.destroy_all
        alarm
      end

      it "422を返す" do
        patch stop_alarm_path(alarm)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "既にストップ済みのアラームのとき" do
      let(:alarm) do
        create(:alarm, creator: user, user_uuid: user.uuid, scheduled_at: 30.minutes.from_now)
      end

      before do
        alarm.alarm_memberships.find_by(user_uuid: user.uuid).stop
      end

      it "422を返す" do
        patch stop_alarm_path(alarm)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "他のユーザーのアラームのとき" do
      let(:other_user)  { create(:user) }
      let(:other_alarm) { create(:alarm, creator: other_user, user_uuid: other_user.uuid) }

      it "404を返す" do
        patch stop_alarm_path(other_alarm)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # =========================================================
  # DELETE /alarms/:id (destroy)
  # =========================================================
  describe "DELETE /alarms/:id" do
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
