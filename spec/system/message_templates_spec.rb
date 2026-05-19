# spec/system/message_templates_spec.rb
require "rails_helper"

RSpec.describe "定型文管理", type: :system do
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

      expect(page).not_to have_text("カテゴリごとにグループ化されます")

      click_button "やめる理由"

      within "#manage_list_content" do
        expect(page).to have_text("テスト定型文")
      end
    end
  end

  describe "定型文の削除" do
    let!(:template) do
      create(:message_template, user_uuid: user.uuid,
             reason: "やめる理由", template: "削除対象の定型文")
    end

    it "削除後にリストから消える" do
      visit manage_message_templates_path

      click_button "やめる理由"

      within "#manage_list_content" do
        expect(page).to have_text("削除対象の定型文")
      end

      accept_confirm do
        click_button "削除"
      end

      expect(page).not_to have_text("削除対象の定型文")
    end
  end
end