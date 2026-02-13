class User < ApplicationRecord
  validates :name, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }, if: -> { uid.present? }
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  #======================================================================================
  # アソシエーション
  #======================================================================================
  has_many :alarms, dependent: :destroy
  has_many :alarm_logs, through: :alarms
  has_many :message_templates, dependent: :destroy
  has_many :bookmarks, dependent: :destroy

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

  # 定型文のブックマークの作成
  def bookmark(message_template)
    bookmarks_message_templates << message_template
  end

  # 定型文のブックマークの削除
  def unbookmark(message_template)
    bookmarks_message_templates.destroy(message_template)
  end
end
