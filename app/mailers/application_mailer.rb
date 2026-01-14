class ApplicationMailer < ActionMailer::Base
  default from: "#{ENV['EMAIL_FROM_NAME']} <noreply@#{ENV['EMAIL_FROM_DOMAIN']}>"
  layout "mailer"
end
