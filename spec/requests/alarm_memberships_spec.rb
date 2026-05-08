# spec/requests/alarm_memberships_spec.rb
require "rails_helper"

RSpec.describe "AlarmMemberships", type: :request do
  let(:user)  { create(:user) }
  let(:alarm) { create(:alarm, creator: user, user_uuid: user.uuid) }

  # =========================================================
  # 未ログインのとき
  # =========================================================
  describe "未ログインのとき" do
    it "GET /alarms/:alarm_id/alarm_memberships/search_users はログイン画面にリダイレクトする" do
      get search_users_alarm_alarm_memberships_path(alarm)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "POST /alarms/:alarm_id/alarm_memberships はログイン画面にリダイレクトする" do
      post alarm_alarm_memberships_path(alarm)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "GET /alarms/:alarm_id/alarm_memberships/:id はログイン画面にリダイレクトする" do
      membership = alarm.alarm_memberships.find_by(user_uuid: user.uuid)
      get alarm_alarm_membership_path(alarm, membership)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "DELETE /alarms/:alarm_id/alarm_memberships/:id はログイン画面にリダイレクトする" do
      membership = alarm.alarm_memberships.find_by(user_uuid: user.uuid)
      delete alarm_alarm_membership_path(alarm, membership)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "PATCH /alarms/:alarm_id/alarm_memberships/:id/stop はログイン画面にリダイレクトする" do
      membership = alarm.alarm_memberships.find_by(user_uuid: user.uuid)
      patch stop_alarm_alarm_membership_path(alarm, membership)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  # =========================================================
  # set_alarmの認可チェック
  # =========================================================
  describe "set_alarmの認可チェック" do
    context "アクセス権限がないユーザー（作成者でもメンバーでもない）のとき" do
      let(:other_user)  { create(:user) }
      let(:other_alarm) { create(:alarm, creator: other_user, user_uuid: other_user.uuid) }

      before { sign_in user }

      it "404を返す" do
        get search_users_alarm_alarm_memberships_path(other_alarm)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # =========================================================
  # GET /alarms/:alarm_id/alarm_memberships/search_users
  # =========================================================
  describe "GET /alarms/:alarm_id/alarm_memberships/search_users" do
    before { sign_in user }

    it "200を返す" do
      get search_users_alarm_alarm_memberships_path(alarm)
      expect(response).to have_http_status(:ok)
    end
  end

  # =========================================================
  # POST /alarms/:alarm_id/alarm_memberships (create)
  # =========================================================
  describe "POST /alarms/:alarm_id/alarm_memberships" do
    before { sign_in user }

    context "フレンドのユーザーを招待するとき" do
      let(:friend) { create(:user) }

      before do
        create(:friendship, user: user, friend: friend, status: :accepted)
      end

      it "200を返す" do
        post alarm_alarm_memberships_path(alarm), params: { user_id: friend.uuid }
        expect(response).to have_http_status(:ok)
      end
    end

    context "フレンドでないユーザーを招待しようとするとき" do
      let(:non_friend) { create(:user) }

      it "422を返す" do
        post alarm_alarm_memberships_path(alarm), params: { user_id: non_friend.uuid }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  # =========================================================
  # GET /alarms/:alarm_id/alarm_memberships/:id (show)
  # =========================================================
  describe "GET /alarms/:alarm_id/alarm_memberships/:id" do
    before { sign_in user }

    let(:membership) { alarm.alarm_memberships.find_by(user_uuid: user.uuid) }

    it "200を返す" do
      get alarm_alarm_membership_path(alarm, membership)
      expect(response).to have_http_status(:ok)
    end
  end

  # =========================================================
  # DELETE /alarms/:alarm_id/alarm_memberships/:id (destroy)
  # =========================================================
  describe "DELETE /alarms/:alarm_id/alarm_memberships/:id" do
    before { sign_in user }

    context "メンバーシップが存在するとき" do
      let(:friend) { create(:user) }
      let!(:membership) do
        create(:friendship, user: user, friend: friend, status: :accepted)
        # フレンドをメンバーとして招待しておく
        alarm.alarm_memberships.create!(user_uuid: friend.uuid)
      end

      it "200を返す" do
        delete alarm_alarm_membership_path(alarm, membership)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  # =========================================================
  # PATCH /alarms/:alarm_id/alarm_memberships/:id/stop (stop)
  # =========================================================
  describe "PATCH /alarms/:alarm_id/alarm_memberships/:id/stop" do
    before { sign_in user }

    let(:alarm) do
      create(:alarm, creator: user, user_uuid: user.uuid, scheduled_at: 30.minutes.from_now)
    end

    context "ストップに成功するとき" do
      let(:membership) { alarm.alarm_memberships.find_by(user_uuid: user.uuid) }

      it "statistic_alarm_logs_pathにリダイレクトする" do
        patch stop_alarm_alarm_membership_path(alarm, membership)
        expect(response).to redirect_to(statistic_alarm_logs_path)
      end
    end

    context "既にストップ済みのとき" do
      let(:membership) { alarm.alarm_memberships.find_by(user_uuid: user.uuid) }

      before do
        membership.stop
      end

      it "pending_alarms_pathにリダイレクトする" do
        patch stop_alarm_alarm_membership_path(alarm, membership)
        expect(response).to redirect_to(pending_alarms_path)
      end
    end
  end
end
