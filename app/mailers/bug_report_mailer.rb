# app/mailers/bug_report_mailer.rb
class BugReportMailer < ApplicationMailer
  def report(body)
    @body = body
    mail(
      to: ENV["OWNER_EMAIL"],
      subject: "【Game Exit】不具合報告が届きました"
    )
  end
end
