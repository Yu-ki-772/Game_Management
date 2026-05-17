# spec/requests/diagnosis_results_spec.rb
require "rails_helper"

RSpec.describe "DiagnosisResults" do
  let(:user) { create(:user) }

  describe "未ログインのとき" do
    it "new はログイン画面にリダイレクトする" do
      get new_diagnosis_result_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "create はログイン画面にリダイレクトする" do
      post diagnosis_results_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "show はログイン画面にリダイレクトする" do
      result = create(:diagnosis_result, user: user)
      get diagnosis_result_path(result)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "new" do
    before { sign_in user }

    it "200を返す" do
      get new_diagnosis_result_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "create" do
    before { sign_in user }

    context "有効なパラメータのとき" do
      let(:answers) do
        (1..8).each_with_object({}) { |i, hash| hash["q#{i}"] = "1" }
      end

      it "diagnosis_result_pathにリダイレクトする" do
        post diagnosis_results_path, params: { answers: answers }
        expect(response).to redirect_to(diagnosis_result_path(DiagnosisResult.last))
      end

      it "DiagnosisResultが1件作成される" do
        expect {
          post diagnosis_results_path, params: { answers: answers }
        }.to change(DiagnosisResult, :count).by(1)
      end

      it "自分の診断結果として作成される" do
        post diagnosis_results_path, params: { answers: answers }
        expect(DiagnosisResult.last.user_uuid).to eq(user.uuid)
      end
    end
  end

  describe "show" do
    before { sign_in user }

    context "自分の診断結果のとき" do
      let(:result) { create(:diagnosis_result, user: user) }

      it "200を返す" do
        get diagnosis_result_path(result)
        expect(response).to have_http_status(:ok)
      end
    end

    context "他のユーザーの診断結果のとき" do
      let(:other_user)   { create(:user) }
      let(:other_result) { create(:diagnosis_result, user: other_user) }

      it "404を返す" do
        get diagnosis_result_path(other_result)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
