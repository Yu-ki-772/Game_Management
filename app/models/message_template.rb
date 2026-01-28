class MessageTemplate < ApplicationRecord
  belongs_to :user, optional: true

  validates :reason, presence: true, length: { maximum: 255 }
  validates :template, presence: true, length: { maximum: 255 }

  # フォームでの、既存の理由表示用
  def self.existing_reasons(user_id)
    where(user_id: [ user_id, nil ])
      .distinct
      .pluck(:reason)
  end
end
