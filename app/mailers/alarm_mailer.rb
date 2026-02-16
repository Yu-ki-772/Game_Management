class AlarmMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.alarm_mailer.alarm_notification.subject
  #
  def alarm_notification(alarm_uuid)
    @alarm = Alarm.find_by(uuid: alarm_uuid)

    return unless @alarm

    @user = @alarm.user


    mail(
      to: @user.email,
      subject: "#{@alarm.label}"
    )
  end
end
