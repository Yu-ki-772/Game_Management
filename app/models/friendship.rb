class Friendship < ApplicationRecord
  belongs_to :user, primary_key: :uuid, foreign_key: :user_uuid
  belongs_to :friend, class_name: "User", primary_key: :uuid, foreign_key: :friend_uuid

  enum :status, { pending: "pending", accepted: "accepted" }, default: :pending

  validates :user_uuid, uniqueness: { scope: :friend_uuid }

  # ユーザとのfriendshipが存在するかでの絞り込み
  scope :between, ->(user1, user2) {
    where(user_uuid: user1.id, friend_uuid: user2.id)
      .or(where(user_uuid: user2.id, friend_uuid: user1.id))
  }
  scope :between_user_and_ids, ->(user, user_uuids) {
    where(user_uuid: user.uuid, friend_uuid: user_uuids)
      .or(where(user_uuid: user_uuids, friend_uuid: user.uuid))
  }

  # friendshipの相手側のユーザを返す
  def partner(user)
    return nil unless accepted?

    if user_uuid == user.uuid
      friend
    else
      self.user
    end
  end
end
