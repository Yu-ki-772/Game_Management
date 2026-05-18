# spec/helpers/application_helper_spec.rb
require "rails_helper"

RSpec.describe ApplicationHelper do
  describe "#format_play_minutes" do
    context "60分以下のとき" do
      it "分で表示する" do
        expect(helper.format_play_minutes(30)).to eq("30分")
      end

      it "60分ちょうどは分で表示する" do
        expect(helper.format_play_minutes(60)).to eq("60分")
      end
    end

    context "60分を超えるとき" do
      context "端数がないとき" do
        it "時間のみで表示する" do
          expect(helper.format_play_minutes(120)).to eq("2時間")
        end
      end

      context "端数があるとき" do
        it "時間と分で表示する" do
          expect(helper.format_play_minutes(90)).to eq("1時間30分")
        end
      end
    end
  end
end
