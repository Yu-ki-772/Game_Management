class Alarm < ApplicationRecord
  belongs_to :creator, foreign_key: "user_uuid", primary_key: "uuid", class_name: "User"
  has_many :alarm_logs, primary_key: :uuid, foreign_key: :alarm_uuid, dependent: :destroy
  has_many :alarm_memberships, foreign_key: "alarm_uuid", primary_key: "uuid", dependent: :destroy
  has_many :members,
           through: :alarm_memberships,
           source: :user

  #=======================================
  # バリデーション
  #=======================================
  validates :label, presence: true, length: { maximum: 255 }
  validates :scheduled_at, presence: true
  validate :scheduled_at_must_be_in_the_future
  validate :started_at_must_be_before_scheduled_at, if: :started_at?

  #=======================================
  # コールバック
  #=======================================
  after_commit :schedule_notification_job, on: [ :create, :update ]
  after_commit :cancel_existing_job, on: :destroy

  #=======================================
  # スコープ
  #=======================================
  scope :unsent, -> { where(sent: false) }
  scope :future, -> { where("scheduled_at > ?", Time.current) }
  scope :locked, -> { where(unlocked: false) }

  # 設定時間（24時間前後）で絞る
  scope :near, -> { where(scheduled_at: 24.hours.ago..24.hours.from_now) }

  # alarm_membershipsテーブルに紐づくalarmだけを返すスコープ
  scope :with_membership, -> { joins(:alarm_memberships).distinct }
  scope :not_unlocked_by, ->(user) {
    where.not(
      uuid: AlarmLog.where(user_uuid: user.uuid).select(:alarm_uuid)
    )
  }

  # カレンダーへの表示用のスコープ
  # started_atがある場合はそれを、ない場合はscheduled_atを期間判定に使用
  scope :in_period, ->(start_date, end_date) {
    where(started_at: ..end_date)
      .where("scheduled_at >= ?", start_date)
      .or(
        where(started_at: nil)
          .where(scheduled_at: start_date..end_date)
      )
  }

  def start_time
    started_at || scheduled_at
  end
  
  def time_text
    if started_at.present?
      "#{started_at.strftime('%H:%M')} - #{scheduled_at.strftime('%H:%M')}"
    else
      scheduled_at.strftime("%H:%M")
    end
  end

  #========================================
  # publicメソッド
  #========================================
   # （アラームをストップ&記録の作成）用のメソッド
  def unlock_with_log
    return [ false, nil ] if unlocked?

    current_time = Time.current
    # 設定時刻と現在時刻の差
    times_defer = current_time - scheduled_at

    alarm_log = alarm_logs.build(
      unlocked_at: current_time,
      minutes_to_unlock: (times_defer / 60).round,
      user_uuid: user_uuid
    )

    return [ false, alarm_log ] unless alarm_log.valid?

    transaction do
      cancel_existing_job if times_defer.negative?

      update_column(:unlocked, true) # ストップ済みに変更（コールバックが実行されない書き方）
      alarm_log.save!
    end

    [ true, alarm_log ]
  end

  def belonging_to_membership?
    alarm_memberships.exists?
  end

  # 作成者かどうかを判定する
  def created_by?(user)
    user_uuid == user.uuid
  end

  def accessible_by?(user)
    created_by?(user) || alarm_memberships.any? { |m| m.user_uuid == user.uuid }
  end


  private

  #=========================================
  # privateメソッド
  #=========================================

  # scheduled_atが未来の日時である場合のみ許可する
  def scheduled_at_must_be_in_the_future
    return if scheduled_at.blank?

    if scheduled_at <= Time.current
      errors.add(:scheduled_at, "は未来の日時を指定してください")
    end
  end

  # 開始時間が鳴る時間よりも前の場合のみ許可
  def started_at_must_be_before_scheduled_at
    return if scheduled_at.blank?

    if started_at >= scheduled_at
      errors.add(:started_at, "はアラーム時刻より前である必要があります")
    end
  end

  # ジョブのスケジューリング
  def schedule_notification_job
    # 同idの既存のジョブがあれば削除
    cancel_existing_job

    # ジョブの作成
    job = AlarmNotificationJob.set(wait_until: scheduled_at).perform_later(uuid)

    # alarmのjob_idを、active_jobのprovider_job_idにする
    update_column(:job_id, job.provider_job_id) if persisted?
  end

  # ジョブの削除
  def cancel_existing_job
    return if job_id.blank?

    # good_jobからjobを削除
    GoodJob::Job.find_by(id: job_id)&.destroy

    # 保存済みの場合のみjob_idをクリア
    update_column(:job_id, nil) if persisted?
  end
end