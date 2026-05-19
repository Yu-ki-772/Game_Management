# spec/system/diagnosis_results_spec.rb
require "rails_helper"

RSpec.describe "ゲーム時間管理度診断", type: :system do
  let(:user) { create(:user) }

  before do
    login_as(user, scope: :user)
    visit new_diagnosis_result_path
  end

  describe "診断フォームの初期状態" do
    it "送信ボタンが無効になっている" do
      expect(page).to have_button("診断結果を見る", disabled: true)
    end

    it "進捗カウンターが 0 / 8 になっている" do
      expect(page).to have_text("0 / 8")
    end
  end

  describe "回答の選択" do
    it "1問回答すると進捗カウンターが 1 / 8 に更新される" do
      all("label", text: "ほとんどない").first.click

      expect(page).to have_text("1 / 8")
    end

    it "全問回答すると送信ボタンが有効になる" do
      all("label", text: "ほとんどない").each(&:click)

      expect(page).to have_button("診断結果を見る", disabled: false)
    end
  end
end