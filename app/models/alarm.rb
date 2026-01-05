class Alarm < ApplicationRecord
  belongs_to :user
  validates :label, presence: true, length: { maximum: 255 }
  validates :scheduled_at, presence: true
  validate :scheduled_at_must_be_in_the_future

  private

  # scheduled_atが未来の日時である場合のみ許可する
  def scheduled_at_must_be_in_the_future
    return if scheduled_at.blank?

    if scheduled_at <= Time.current
      errors.add(:scheduled_at, "は未来の日時を指定してください")
    end
  end
end
