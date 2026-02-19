class AlarmLog < ApplicationRecord
  # アソシエーション
  belongs_to :alarm, primary_key: :uuid, foreign_key: :alarm_uuid
  belongs_to :user, primary_key: :uuid, foreign_key: :user_uuid, optional: true

  # バリデーション
  validate :minutes_to_unlock_range

  # コールバック


  # 60分以上遅れた場合を「長すぎ」と判定する。
  def ignored?
    minutes_to_unlock >= 60
  end

  private


  # アラームのストップは、設定時間から1440分(24時間)前後の場合のみ受け付ける
  def minutes_to_unlock_range
    if minutes_to_unlock < -1440 || minutes_to_unlock > 1440
      errors.add(:base, "ストップは、アラームの設定時刻から24時間前後の範囲内で行ってください")
    end
  end
end
