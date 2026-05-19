# spec/system/alarm_memberships_spec.rb
require "rails_helper"

RSpec.describe "アラームメンバー管理", type: :system do
  let(:creator) { create(:user) }
  let(:friend)  { create(:user) }
  let!(:alarm) do
    create(:alarm, creator: creator, user_uuid: creator.uuid, scheduled_at: 1.day.from_now)
  end

  before do
    allow_any_instance_of(Alarm).to receive(:schedule_notification_job)
    create(:friendship, user: creator, friend: friend, status: :accepted)
    login_as(creator, scope: :user)
  end

  describe "フレンドの招待" do
    it "招待ボタンが「招待済み」に切り替わる" do
      visit alarms_path

      within "#alarms_list" do
        click_button "招待"
      end
      fill_in "名前で検索", with: friend.name

      expect(page).to have_button("招待する")
      click_button "招待する"

      expect(page).to have_button("招待済み")
    end
  end

  describe "フレンドの招待解除" do
    before do
      create(:alarm_membership,
        alarm: alarm, alarm_uuid: alarm.uuid,
        user: friend, user_uuid: friend.uuid)
    end

    it "解除後にボタンが「招待する」に切り替わる" do
      visit alarms_path

      within "#alarms_list" do
        click_button "招待"
      end
      fill_in "名前で検索", with: friend.name

      expect(page).to have_button("招待済み")
      click_button "招待済み"

      expect(page).to have_button("招待する")
    end
  end
end