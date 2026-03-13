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

    # アラームのストップは設定時刻から24時間（1440分）前後の範囲内のみ受け付ける
    describe "minutes_to_unlock_range" do
      context "範囲内の場合" do
        it "0分のとき有効である" do
          expect(build(:alarm_log, minutes_to_unlock: 0)).to be_valid
        end

        # 境界値：-1440 と 1440 はちょうど条件式の端
        it "-1440分（境界値）のとき有効である" do
          expect(build(:alarm_log, minutes_to_unlock: -1440)).to be_valid
        end

        it "1440分（境界値）のとき有効である" do
          expect(build(:alarm_log, minutes_to_unlock: 1440)).to be_valid
        end
      end

      context "範囲外の場合" do
        it "-1441分のとき base にエラーが追加される" do
          log = build(:alarm_log, minutes_to_unlock: -1441)
          log.valid?
          expect(log.errors[:base]).not_to be_empty
        end

        it "1441分のとき base にエラーが追加される" do
          log = build(:alarm_log, minutes_to_unlock: 1441)
          log.valid?
          expect(log.errors[:base]).not_to be_empty
        end
      end
    end
  end
end