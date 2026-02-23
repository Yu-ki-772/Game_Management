class ReflectionNote < ApplicationRecord
  belongs_to :user, foreign_key: :user_uuid, primary_key: :uuid
  has_many   :reflection_note_tags, dependent: :destroy
  has_many   :tags, through: :reflection_note_tags

  # Enum  (1: 要改善  2: 成功  3: 疑問・仮説)
  enum :reflection_type, {
    improvement: 1,
    success: 2,
    hypothesis: 3
  }, prefix: true



  # ------------------------------------------------------------------ #
  # バリデーション
  # ------------------------------------------------------------------ #
  validates :title,           length: { maximum: 255 }, allow_blank: true
  validates :body,            presence: true, length: { maximum: 3000 }
  validates :reflection_type, presence: true

  # ------------------------------------------------------------------ #
  # スコープ — reflection_type 絞込
  # ------------------------------------------------------------------ #
  scope :by_type, ->(type) {
    return all unless reflection_types.key?(type.to_s)
    public_send(type)  # モデル内部での使用なので安全
  }

  # ------------------------------------------------------------------ #
  # スコープ — 期間絞込
  # ------------------------------------------------------------------ #
  scope :this_week,     -> { where(created_at: Time.current.beginning_of_week..Time.current.end_of_week) }
  scope :this_month,    -> { where(created_at: Time.current.beginning_of_month..Time.current.end_of_month) }
  scope :last_3_months, -> { where(created_at: 3.months.ago.beginning_of_day..Time.current) }
  scope :last_6_months, -> { where(created_at: 6.months.ago.beginning_of_day..Time.current) }
  scope :last_year,     -> { where(created_at: 1.year.ago.beginning_of_day..Time.current) }

  VALID_PERIODS = %w[this_week this_month last_3_months last_6_months last_year].freeze

  def self.by_period(period)
    return all unless VALID_PERIODS.include?(period.to_s)
    public_send(period)
  end

  # タグ同期（ビジネスロジックはモデルに集約）
  def sync_tags(tag_ids:, new_tag_names:)
    # 既存タグを一括取得
    tags_to_assign = user.tags.where(id: Array(tag_ids).reject(&:blank?)).to_a

    # 新規タグ：find_or_create_by! で競合状態を防ぐ
    if new_tag_names.present?
      new_tag_names.split(",").map(&:strip).reject(&:blank?).uniq.each do |name|
        tags_to_assign << user.tags.find_or_create_by!(name: name)
      end
    end

    # 新規タグを既存タグに追加
    self.tags = tags_to_assign
  end

  #------------------------------
  # Ransack（検索） 許可設定
  #------------------------------
  def self.ransackable_attributes(_auth_object = nil)
    %w[title body reflection_type]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[tags]
  end
end
