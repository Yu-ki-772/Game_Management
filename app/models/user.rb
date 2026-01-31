class User < ApplicationRecord
  validates :name, presence: true
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

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
  # 定型文のブックマークの作成
  def bookmark(message_template)
    bookmarks_message_templates << message_template
  end

  # 定型文のブックマークの削除
  def unbookmark(message_template)
    bookmarks_message_templates.destroy(message_template)
  end
end
