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
end
