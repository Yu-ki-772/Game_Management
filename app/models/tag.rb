class Tag < ApplicationRecord
  belongs_to :user, foreign_key: :user_uuid, primary_key: :uuid
  has_many :reflection_note_tag, dependent: :destroy
  has_many :reflection_note, through: :reflection_note_tag

  validates :name, presence: true, length: { maximum: 18 }
  validates :name, uniqueness: { scope: :user_uuid }
end
