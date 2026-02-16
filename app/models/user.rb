class User < ApplicationRecord
  validates :name, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }, if: -> { uid.present? }
  validates :description, length: { maximum: 255 }
  validate :avatar_content_type
  validate :avatar_size

  scope :non_admin, -> { where(admin: false) } # 管理者ユーザかどうかの確認
  

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_one_attached :avatar # active_storage用
  #======================================================================================
  # アソシエーション
  #======================================================================================
  has_many :alarms, dependent: :destroy
  has_many :alarm_logs, through: :alarms
  has_many :message_templates, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :friendships, dependent: :destroy
  has_many :received_friendships,
              class_name: 'Friendship',
              foreign_key: 'friend_id',
              dependent: :destroy

  # ブックマークした定型文
  has_many :bookmarks_message_templates, through: :bookmarks, source: :message_template
  
  #========================================================
  # publicメソッド
  #========================================================
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |new_user|
      new_user.name = auth.info.name
      new_user.email = auth.info.email
      new_user.password = Devise.friendly_token[0, 20]
    end
  end

  # uuid化用
  def self.create_unique_string
    SecureRandom.uuid
  end

  # バリデーション用
  def avatar_content_type
    if avatar.attached? && !avatar.content_type.in?(%w[image/jpeg image/png])
      errors.add(:avatar, "：ファイル形式が、JPEG, PNG以外になってます。ファイル形式をご確認ください。")
    end
  end

  # バリデーション用
  def avatar_size
    if avatar.attached? && avatar.blob.byte_size > 2.megabytes
      errors.add(:avatar, "：2MB以下のファイルをアップロードしてください。")
    end
  end

  def avatar_image?
    avatar.attached? && avatar.content_type.in?(%w[image/jpeg image/png])
  end

  # ransackで検索可能なもの
  def self.ransackable_attributes(auth_object = nil)
    ["name"]
  end

  # フレンド申請の送信（friendshipの作成）
  def send_friend_request(other_user)
    friendships.create(friend: other_user, status: 'pending')
  end

  # friendshipのstatusの確認時に使うもの
  def friendship_statuses_for(user_ids)
    {
      pending_requests: received_friendships.pending.where(user_id: user_ids).index_by(&:user_id),
      friendships: Friendship.between_user_and_ids(self, user_ids).index_by { |f| 
        f.user_id == id ? f.friend_id : f.user_id 
      }
    }
  end

  # 対象ユーザからフレンドリクエストが来ているかの確認
  def pending_request_from?(other_user)
    received_friendships.pending.find_by(user_id: other_user.id)
  end

  # 対象ユーザとのfriendshipデータの取得
  def friendship_with(other_user)
    Friendship.between(self, other_user).first
  end

  # 定型文のブックマークの作成
  def bookmark(message_template)
    bookmarks_message_templates << message_template
  end

  # 定型文のブックマークの削除
  def unbookmark(message_template)
    bookmarks_message_templates.destroy(message_template)
  end
end
