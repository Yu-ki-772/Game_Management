# spec/mailers/bug_report_mailer_spec.rb
require "rails_helper"

RSpec.describe BugReportMailer do
  describe "#report" do
    let(:body) { "ログインできません" }
    let(:mail) { described_class.report(body) }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("OWNER_EMAIL").and_return("owner@example.com")
    end

    it "宛先が OWNER_EMAIL であること" do
      expect(mail.to).to eq(["owner@example.com"])
    end

    it "送信元が noreply@ であること" do
      expect(mail.from.first).to start_with("noreply@")
    end

    it "件名が正しいこと" do
      expect(mail.subject).to eq("【Game Exit】不具合報告が届きました")
    end

    it "本文に報告内容が含まれること" do
      expect(mail.body.encoded).to include(body)
    end
  end
end