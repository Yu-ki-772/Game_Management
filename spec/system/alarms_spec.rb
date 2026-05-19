# spec/system/alarms_spec.rb
require "rails_helper"

RSpec.describe "アラーム管理" do
  let(:user) { create(:user) }

  before { login_as(user, scope: :user) }

  describe "アラームの作成" do
    it "作成後に alarms_list が更新されダイアログが閉じる" do
      visit alarms_path

      click_link "アラームを作成", match: :first

      within "dialog" do
        fill_in "alarm[label]", with: "テストアラーム"
        fill_in "alarm[scheduled_at]", with: 1.day.from_now.strftime("%Y-%m-%dT%H:%M")
        click_button "アラームを作成"
      end

      within "#alarms_list" do
        expect(page).to have_text("テストアラーム")
      end
      expect(page).to have_no_text("日時とラベルを設定してください")
    end
  end

  describe "アラームの更新" do
    before do
      create(:alarm, creator: user, user_uuid: user.uuid,
             label: "旧ラベル", scheduled_at: 1.day.from_now)
    end

    it "更新後に alarms_list が更新されダイアログが閉じる" do
      visit alarms_path

      click_link "編集"

      within "dialog" do
        fill_in "alarm[label]", with: "新ラベル"
        click_button "更新する"
      end

      within "#alarms_list" do
        expect(page).to have_text("新ラベル")
      end
      expect(page).to have_no_text("日時とラベルを設定してください")
    end
  end
end
