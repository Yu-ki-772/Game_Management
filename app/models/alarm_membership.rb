class AlarmMembership < ApplicationRecord
  belongs_to :user, foreign_key: "user_uuid",  primary_key: "uuid"
  belongs_to :alarm, foreign_key: "alarm_uuid", primary_key: "uuid"

  validate :user_must_be_friend_of_creator, unless: :creator?

  # 指定したユーザーがまだストップしていないメンバーシップだけを返す。
  scope :not_stopped_by, ->(user) {
    where.not(
      alarm_uuid: AlarmLog.where(user_uuid: user.uuid).select(:alarm_uuid)
    )
  }

  # アラームをストップ済みかどうかを判定する。
  def stopped?
    alarm.alarm_logs.exists?(user_uuid: user_uuid)
  end

  def stop
    return false if stopped?

    current_time = Time.current
    times_defer = current_time - alarm.scheduled_at
    started = alarm.started_at.present? && alarm.started_at < current_time

    alarm_log = alarm.alarm_logs.build(
      stopped_at: current_time,
      minutes_to_stop: (times_defer / 60).round,
      user_uuid: user_uuid,
      play_duration: started ? ((current_time - alarm.started_at) / 60).round : nil
    )

    return false unless alarm_log.valid?

    ActiveRecord::Base.transaction do
      alarm_log.save!

      # ログ保存後に全員ストップ済みかチェック
      if all_members_stopped?
        alarm.cancel_existing_job if times_defer.negative?
        alarm.update_column(:stopped, true)
      end
    end

    alarm_log
  rescue ActiveRecord::RecordInvalid
    nil
  end

  private

  # 全員がストップ済みかどうかの確認
  def all_members_stopped?
    alarm.alarm_memberships
        .where.not(user_uuid: alarm.alarm_logs.select(:user_uuid))
        .none?
  end

  # 招待されるユーザーがアラーム作成者のフレンドかどうかを確認
  def user_must_be_friend_of_creator
    creator = alarm.creator

    unless Friendship.accepted.between(creator, user).exists?
      errors.add(:user_uuid, "はフレンドのみ招待できます")
    end
  end

  # アラームの作成者かどうかの確認
  def creator?
    user_uuid == alarm.user_uuid
  end
end
