module AlarmsHelper
  # モーダルでの表示用
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

  # Xでのalarm_logの共有用
  def x_share_url_for_alarm_log(alarm_log)
    base_url = "https://x.com/intent/tweet"

    log = format_minutes_defer_for_share(alarm_log.minutes_to_unlock)

    share_data = {
      text: "目標時間に対し、#{log}ゲームを終了しました！",
      url: ENV.fetch("APP_URL", "http://localhost:3000"),
      hashtags: "ゲーム,時間管理,GameExit"
    }

    "#{base_url}?#{share_data.to_query}"
  end

  DISPLAY_MEMBERS_LIMIT = 3

  # 表示するメンバーを上限人数に絞って返す
  def alarm_display_members(alarm)
    alarm.members.first(DISPLAY_MEMBERS_LIMIT)
  end

  # 表示しきれなかったメンバーの人数を返す
  def alarm_hidden_members_count(alarm)
    alarm.members.size - DISPLAY_MEMBERS_LIMIT
  end
end
