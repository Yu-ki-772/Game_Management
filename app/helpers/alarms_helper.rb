# app/helpers/alarms_helper.rb
module AlarmsHelper
  # モーダル・一覧画面での表示用
  def format_minutes_defer(minutes)
    return if minutes.nil?

    # 絶対値に変換
    abs_minutes = minutes.abs

    # 正負の判定
    case
    when minutes > 0
      "#{abs_minutes}分遅れ"
    when minutes < 0
      "#{abs_minutes}分早め"
    else
      "ちょうど"
    end
  end

  # Xでのalarm_log共有時のtext用
  def format_minutes_defer_for_share(minutes)
    return if minutes.nil?

    # 絶対値に変換
    abs_minutes = minutes.abs

    # 正負の判定
    case
    when minutes > 0
      "「#{abs_minutes}分遅れ」で"
    when minutes < 0
      "「#{abs_minutes}分早め」に"
    else
      "「時間ちょうど」で"
    end
  end

  # プレイ時間の表示
  def format_play_minutes(minutes)
    return "#{minutes}分" if minutes <= 60

    hours = minutes / 60    # 時間（切り捨て）
    mins  = minutes % 60    # 残りの分

    if mins.zero?
      "#{hours}時間"
    else
      "#{hours}時間#{mins}分"
    end
  end

  # Xでのalarm_logの共有用
  def x_share_url_for_alarm_log(alarm_log)
    base_url = "https://x.com/intent/tweet"

    log = format_minutes_defer_for_share(alarm_log.minutes_to_unlock)
    play_duration = format_play_minutes(alarm_log.play_duration)

    share_data = {
      text: "目標時間から#{log}ゲームを終了。 プレイ時間: #{play_duration}",
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
