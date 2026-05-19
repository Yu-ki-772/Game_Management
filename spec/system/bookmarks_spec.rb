# spec/system/bookmarks_spec.rb
require "rails_helper"

RSpec.describe "ブックマーク管理" do
  let(:user) { create(:user) }

  before do
    create(:message_template, user_uuid: user.uuid,
           reason: "やめる理由", template: "定型文テキスト")
    login_as(user, scope: :user)
  end

  describe "ブックマークの追加" do
    it "ブックマークボタンをクリックすると解除ボタンに切り替わる" do
      template = user.message_templates.first
      visit manage_message_templates_path

      click_button "やめる理由"

      within "#bookmark_button_#{template.id}" do
        find("button").click # rubocop:disable Capybara/SpecificActions
      end

      expect(page).to have_css("#bookmark_button_#{template.id} button.text-yellow-500")
    end
  end

  describe "ブックマークの解除" do
    before do
      create(:bookmark, user_uuid: user.uuid,
             message_template: user.message_templates.first)
    end

    it "解除ボタンをクリックするとブックマークボタンに切り替わる" do
      template = user.message_templates.first
      visit manage_message_templates_path

      click_button "やめる理由"

      within "#bookmark_button_#{template.id}" do
        find("button").click # rubocop:disable Capybara/SpecificActions
      end

      expect(page).to have_css("#bookmark_button_#{template.id} button.text-gray-400")
    end
  end
end
