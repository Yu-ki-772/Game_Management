# spec/system/bookmarks_spec.rb
require "rails_helper"

RSpec.describe "ブックマーク管理", type: :system do
  let(:user)      { create(:user) }
  let!(:template) do
    create(:message_template, user_uuid: user.uuid,
           reason: "やめる理由", template: "定型文テキスト")
  end

  before { login_as(user, scope: :user) }

  describe "ブックマークの追加" do
    it "ブックマークボタンをクリックすると解除ボタンに切り替わる" do
      visit manage_message_templates_path

      click_button "やめる理由"

      within "#bookmark_button_#{template.id}" do
        find("button").click
      end

      expect(page).to have_css("#bookmark_button_#{template.id} button.text-yellow-500")
    end
  end

  describe "ブックマークの解除" do
    let!(:bookmark) do
      create(:bookmark, user_uuid: user.uuid, message_template: template)
    end

    it "解除ボタンをクリックするとブックマークボタンに切り替わる" do
      visit manage_message_templates_path

      click_button "やめる理由"

      within "#bookmark_button_#{template.id}" do
        find("button").click
      end

      expect(page).to have_css("#bookmark_button_#{template.id} button.text-gray-400")
    end
  end
end