class AlarmMailer < ApplicationMailer
  # 作成者への通知
  def alarm_notification(alarm_uuid)
    @alarm = Alarm.find_by(uuid: alarm_uuid)
    return unless @alarm

    @user = @alarm.creator

    mail(
      to: @user.email,
      subject: @alarm.label
    )
  end

  # メンバーへの通知（新規追加）
  def member_alarm_notification(alarm_uuid, member_uuid)
    @alarm = Alarm.find_by(uuid: alarm_uuid)
    @user = User.find_by(uuid: member_uuid)

    # どちらかが見つからない場合は送信をスキップする
    return unless @alarm && @user

    mail(
      to: @user.email,
      subject: @alarm.label
    )
  end

  def alarm_reminder(alarm_uuid, minutes_until_alarm)
    @alarm = Alarm.find_by(uuid: alarm_uuid)
    mail(to: @alarm.creator.email, subject: "【#{@alarm.reminder_minutes}分前】#{@alarm.label}")
  end

  def member_alarm_reminder(alarm_uuid, member_uuid, minutes_until_alarm)
    @alarm = Alarm.find_by(uuid: alarm_uuid)
    @member = User.find_by(uuid: member_uuid)
    mail(to: @member.email, subject: "【#{@alarm.reminder_minutes}分前】#{@alarm.label}")
  end
end
