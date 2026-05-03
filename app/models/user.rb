class User < ApplicationRecord
  validates :name, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }, if: -> { uid.present? }
  validates :description, length: { maximum: 255 }
  validate :avatar_content_type
  validate :avatar_size




  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :lockable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_one_attached :avatar # active_storage用
  #======================================================================================
  # アソシエーション
  #======================================================================================
  has_many :alarms, primary_key: :uuid, foreign_key: :user_uuid, dependent: :destroy
  has_many :alarm_logs, through: :alarms
  has_many :direct_alarm_logs, class_name: "AlarmLog",
              foreign_key: "user_uuid", primary_key: "uuid", dependent: :destroy
  has_many :message_templates, primary_key: :uuid, foreign_key: :user_uuid, dependent: :destroy
  has_many :bookmarks, primary_key: :uuid, foreign_key: :user_uuid, dependent: :destroy
  has_many :friendships, primary_key: :uuid, foreign_key: :user_uuid, dependent: :destroy
  has_many :received_friendships,
              class_name: "Friendship",
              primary_key: :uuid,
              foreign_key: :friend_uuid,
              dependent: :destroy
  has_many :alarm_memberships, foreign_key: "user_uuid", primary_key: "uuid", dependent: :destroy
  has_many :member_alarms,
           through: :alarm_memberships,
           source: :alarm

  # ブックマークした定型文
  has_many :bookmarks_message_templates, through: :bookmarks, source: :message_template


  has_many :web_push_subscriptions, foreign_key: :user_uuid, primary_key: :uuid, dependent: :destroy

  has_many :diagnosis_results,
         primary_key: :uuid,
         foreign_key: :user_uuid,
         dependent: :destroy

  scope :non_admin, -> { where(admin: false) } # 管理者ユーザかどうかの確認



  # フレンドのみに絞込
  def self.friends_with(user)
    # 「自分が申請した」フレンドのuuidをサブクエリで取得する。
    sent_friend_uuids = Friendship.accepted
                                  .where(user_uuid: user.uuid)
                                  .select(:friend_uuid)

    # 「相手から申請された」フレンドのuuidをサブクエリで取得する。
    received_friend_uuids = Friendship.accepted
                                      .where(friend_uuid: user.uuid)
                                      .select(:user_uuid)

    # 両方のサブクエリをORでつなぎ、どちらの方向のフレンドも拾う。
    where(uuid: sent_friend_uuids).or(where(uuid: received_friend_uuids))
  end

  #========================================================
  # publicメソッド
  #========================================================
  # ログイン状態を維持するのを通常にする
  def remember_me
    true
  end

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
    [ "name" ]
  end

  # フレンド申請の送信（friendshipの作成）
  def send_friend_request(other_user)
    friendships.create(friend: other_user, status: "pending")
  end

  # friendshipのstatusの確認時に使うもの
  def friendship_statuses_for(user_uuids)
    {
      pending_requests: received_friendships.pending.where(user_uuid: user_uuids).index_by(&:user_uuid),
      friendships: Friendship.between_user_and_ids(self, user_uuids).index_by { |f|
        f.user_uuid == id ? f.friend_uuid : f.user_uuid
      }
    }
  end

  # 対象ユーザからフレンドリクエストが来ているかの確認
  def pending_request_from?(other_user)
    received_friendships.pending.find_by(user_uuid: other_user.uuid)
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

  # アバター画像をリサイズして添付する
  def attach_resized_avatar(avatar_file)
    # 2MB以下かどうかをリサイズ前に確認
    if avatar_file.size > 2.megabytes
      errors.add(:avatar, "：2MB以下のファイルをアップロードしてください。")
      return false
    end

    # リサイズ
    resized_image = ImageProcessing::Vips
                .source(avatar_file)
                .resize_to_fill(200, 200)
                .call

    # 添付
    avatar.attach(
      io: resized_image,
      filename: avatar_file.original_filename,
      content_type: avatar_file.content_type
    )
  end
end
