class AlarmMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.alarm_mailer.alarm_notification.subject
  #
  def alarm_notification(alarm_id)
    @alarm = Alarm.includes(:user).find_by(id: alarm_id)

    return unless @alarm

    @user = @alarm.user


    mail(
      to: @user.email,
      subject: "#{@alarm.label}"
    )
  end
end
