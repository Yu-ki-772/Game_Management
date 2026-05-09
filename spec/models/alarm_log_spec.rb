# spec/models/alarm_log_spec.rb
require "rails_helper"

RSpec.describe AlarmLog, type: :model do
  subject { build(:alarm_log) }

  # ============================================================
  # アソシエーション
  # ============================================================
  describe "associations" do
    it do
      is_expected.to belong_to(:alarm)
        .with_primary_key(:uuid)
        .with_foreign_key(:alarm_uuid)
    end

    # optional: true のため、user が nil でも有効であることも合わせて検証
    it do
      is_expected.to belong_to(:user)
        .with_primary_key(:uuid)
        .with_foreign_key(:user_uuid)
        .optional
    end
  end

  # ============================================================
  # バリデーション
  # ============================================================
  describe "validations" do
    # アラームのストップは、設定時間から300分(5時間)前後の場合のみ受け付ける
    describe "minutes_to_stop_range" do
      context "範囲内の場合" do
        it "0分のとき有効である" do
          expect(build(:alarm_log, minutes_to_stop: 0)).to be_valid
        end

        it "-299分（境界値）のとき有効である" do
          expect(build(:alarm_log, minutes_to_stop: -299)).to be_valid
        end

        it "299分（境界値）のとき有効である" do
          expect(build(:alarm_log, minutes_to_stop: 299)).to be_valid
        end
      end

      context "範囲外の場合" do
        it "-300分のとき base にエラーが追加される" do
          log = build(:alarm_log, minutes_to_stop: -300)
          log.valid?
          expect(log.errors[:base]).not_to be_empty
        end

        it "300分のとき base にエラーが追加される" do
          log = build(:alarm_log, minutes_to_stop: 300)
          log.valid?
          expect(log.errors[:base]).not_to be_empty
        end
      end
    end
  end
end
