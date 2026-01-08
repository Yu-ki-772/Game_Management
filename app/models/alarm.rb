class Alarm < ApplicationRecord
  belongs_to :user

  # バリデーション
  validates :label, presence: true, length: { maximum: 255 }
  validates :scheduled_at, presence: true
  validate :scheduled_at_must_be_in_the_future

  # コールバック
  after_commit :schedule_notification_job, on: [ :create, :update ]
  after_commit :cancel_existing_job, on: :destroy

  # スコープ
  scope :unsent, -> { where(sent: false) }
  scope :future, -> { where("scheduled_at > ?", Time.current) }

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
