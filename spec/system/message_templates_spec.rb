# spec/system/message_templates_spec.rb
require "rails_helper"

RSpec.describe "定型文管理" do
  let(:user) { create(:user) }

  before { login_as(user, scope: :user) }

  describe "定型文の作成" do
    it "作成後にリストが更新されダイアログが閉じる" do
      visit manage_message_templates_path

      click_link "定型文を作成"

      within "dialog" do
        fill_in "message_template[reason]", with: "やめる理由"
        fill_in "message_template[template]", with: "テスト定型文"
        click_button "作成する"
      end

      expect(page).to have_no_text("カテゴリごとにグループ化されます")

      find("button", text: "やめる理由").click

      within "#manage_list_content" do
        expect(page).to have_text("テスト定型文")
      end
    end
  end

  describe "定型文の削除" do
    before do
      create(:message_template, user_uuid: user.uuid,
             reason: "やめる理由", template: "削除対象の定型文")
    end

    it "削除後にリストから消える" do
      visit manage_message_templates_path

      find("button", text: "やめる理由").click

      within "#manage_list_content" do
        expect(page).to have_text("削除対象の定型文")
      end

      accept_confirm do
        click_button "削除"
      end

      expect(page).to have_no_text("削除対象の定型文")
    end
  end
end