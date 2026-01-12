class Alarm < ApplicationRecord
  belongs_to :user
  has_one :alarm_log, dependent: :destroy

  #=======================================
  # バリデーション
  #=======================================
  validates :label, presence: true, length: { maximum: 255 }
  validates :scheduled_at, presence: true
  validate :scheduled_at_must_be_in_the_future

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

  #========================================
  # publicメソッド
  #========================================
  # （アラームを解除&記録の作成）用のメソッド
  def unlock_with_log
    return [ false, nil ] if unlocked?

    current_time = Time.current

    # 設定時刻と現在時刻の差
    times_defer = current_time - scheduled_at

    # alarm_logのレコード作成
    alarm_log = build_alarm_log(
      unlocked_at: current_time,
      minutes_to_unlock: (times_defer / 60).round # 分に変換
    )

    # バリデーションチェック
    return [ false, alarm_log ] unless alarm_log.valid?

    transaction do
      # 設定時刻よりも前に解除した場合、アラーム通知用のジョブをキャンセル
      cancel_existing_job if times_defer.negative?

      # 解除済みに変更（コールバックが実行されない書き方）
      update_column(:unlocked, true)

      alarm_log.save! # alarm_logのレコードを保存
    end

    [ true, alarm_log ]
  end

  private

  # scheduled_atが未来の日時である場合のみ許可する
  def scheduled_at_must_be_in_the_future
    return if scheduled_at.blank?

    if scheduled_at <= Time.current
      errors.add(:scheduled_at, "は未来の日時を指定してください")
    end
  end

  # ジョブのスケジューリング
  def schedule_notification_job
    # 同idの既存のジョブがあれば削除
    cancel_existing_job

    # ジョブの作成
    job = AlarmNotificationJob.set(wait_until: scheduled_at).perform_later(id)

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
