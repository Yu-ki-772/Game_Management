# app/helpers/alarm_logs_helper.rb
module AlarmLogsHelper
  # 記録画面の分数用のフォーマット
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
end
