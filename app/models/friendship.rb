class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  enum :status, { pending: "pending", accepted: "accepted" }, default: :pending

  validates :user_id, uniqueness: { scope: :friend_id }

  # ユーザとのfriendshipが存在するかでの絞り込み
  scope :between, ->(user1, user2) {
    where(user_id: user1.id, friend_id: user2.id)
      .or(where(user_id: user2.id, friend_id: user1.id))
  }
  scope :between_user_and_ids, ->(user, user_ids) {
    where(user_id: user.id, friend_id: user_ids)
      .or(where(user_id: user_ids, friend_id: user.id))
  }

  # friendshipの相手側のユーザを返す
  def partner(user)
    return nil unless accepted?

    if user_id == user.id
      friend
    else
      self.user
    end
  end
end
