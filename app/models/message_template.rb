class MessageTemplate < ApplicationRecord
  belongs_to :user, primary_key: :uuid, foreign_key: :user_uuid, optional: true
  has_many :bookmarks, dependent: :destroy

  validates :reason, presence: true, length: { maximum: 255 }
  validates :template, presence: true, length: { maximum: 255 }

  # フォームでの、既存の理由表示用
  def self.existing_reasons(user_uuid)
    where(user_uuid: [ user_uuid, nil ])
      .distinct
      .pluck(:reason)
  end
end
