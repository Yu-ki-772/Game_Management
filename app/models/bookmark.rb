class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :message_template

  validates :user_id, uniqueness: { scope: :message_template_id }
end
