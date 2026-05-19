# spec/system/friendships_spec.rb
require "rails_helper"

RSpec.describe "フレンド管理" do
  let(:user)   { create(:user) }
  let(:target) { create(:user) }

  before { login_as(user, scope: :user) }

  describe "フレンド申請" do
    it "申請後にボタンが「申請済み」に切り替わる" do
      visit users_path(q: { name_cont: target.name })

      click_button "フレンド申請"

      expect(page).to have_text("申請済み")
    end
  end

  describe "フレンド申請の承認" do
    before { create(:friendship, user: target, friend: user, status: :pending) }

    it "承認後に pending リストから消える" do
      visit pending_friendships_path

      within "#pending_list_section" do
        expect(page).to have_text(target.name)
      end

      click_button "承認"

      expect(page).to have_no_css("#pending_list_section", text: target.name)
    end
  end

  describe "フレンド関係の解除" do
    before { create(:friendship, user: user, friend: target, status: :accepted) }

    it "解除後にリストから消える" do
      visit friendships_path

      within "#friends_list_section" do
        expect(page).to have_text(target.name)
      end

      accept_confirm do
        click_button "解除"
      end

      expect(page).to have_no_css("#friends_list_section", text: target.name)
    end
  end
end
