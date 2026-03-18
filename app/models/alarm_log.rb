class AlarmLog < ApplicationRecord
  # アソシエーション
  belongs_to :alarm, primary_key: :uuid, foreign_key: :alarm_uuid
  belongs_to :user, primary_key: :uuid, foreign_key: :user_uuid, optional: true

  # バリデーション
  validate :minutes_to_unlock_range


  private


  # アラームのストップは、設定時間から1440分(24時間)前後の場合のみ受け付ける
  def minutes_to_unlock_range
    if minutes_to_unlock <= -300 || minutes_to_unlock >= 300
      errors.add(:base, "ストップは、アラームの設定時刻から5時間前後の範囲内で行ってください")
    end
  end
end
