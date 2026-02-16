class Bookmark < ApplicationRecord
  belongs_to :user, primary_key: :uuid, foreign_key: :user_uuid
  belongs_to :message_template

  validates :user_uuid, uniqueness: { scope: :message_template_id }
end
