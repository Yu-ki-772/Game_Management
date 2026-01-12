class AlarmLog < ApplicationRecord
  # アソシエーション
  belongs_to :alarm

  # バリデーション
  validate :minutes_to_unlock_range

  # コールバック
  after_create :mark_alarm_as_ignored_if_late

  private

  # アラームを解除時刻が設定時刻よりも６０分以上遅いかどうかの判定
  def mark_alarm_as_ignored_if_late
    if minutes_to_unlock >= 60
      alarm.update_column(:ignored, true)
    end
  end

  # アラームの解除は、設定時間から1440分(24時間)前後の場合のみ受け付ける
  def minutes_to_unlock_range
    if minutes_to_unlock < -1440 || minutes_to_unlock > 1440
      errors.add(:base, "解除は、アラームの設定時刻から24時間前後の範囲内で行ってください")
    end
  end
end
