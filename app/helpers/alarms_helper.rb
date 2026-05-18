# app/helpers/alarms_helper.rb
module AlarmsHelper
  # Xでのalarm_logの共有用
  def x_share_url_for_alarm_log(alarm_log)
    base_url = "https://x.com/intent/tweet"

    minutes_to_stop = format_play_minutes(alarm_log.minutes_to_stop)
    play_duration     = format_play_minutes(alarm_log.play_duration)

    share_data = {
      text: "プレイ時間: #{play_duration}\n目標に対する引き延ばし時間: #{minutes_to_stop}",
      url: ENV.fetch("APP_URL", "http://localhost:3000"),
      hashtags: "ゲーム,時間管理,GameExit"
    }

    "#{base_url}?#{share_data.to_query}"
  end

  DISPLAY_MEMBERS_LIMIT = 3

  # 作成者を除いたメンバーリストを返す
  def non_creator_members(alarm)
    alarm.members.reject { |member| member.uuid == alarm.creator.uuid }
  end

  # 表示するメンバーを上限人数に絞って返す
  def alarm_display_members(alarm)
    non_creator_members(alarm).first(DISPLAY_MEMBERS_LIMIT)
  end

  # 表示しきれなかったメンバーの人数を返す
  def alarm_hidden_members_count(alarm)
    non_creator_members(alarm).size - DISPLAY_MEMBERS_LIMIT
  end

  # リマインダーの設定表示用
  def reminder_label(alarm)
    return nil if alarm.reminder_minutes.blank?

    if alarm.reminder_minutes >= 60
      "#{alarm.reminder_minutes / 60}時間前にリマインダー"
    else
      "#{alarm.reminder_minutes}分前にリマインダー"
    end
  end

  # ストップ可能かどうかの条件分岐
  def stoppable?(alarm)
    range = (alarm.scheduled_at - 5.hours)..(alarm.scheduled_at + 5.hours)

    range.cover?(Time.current)
  end
end
