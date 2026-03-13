# spec/models/alarm_spec.rb
require "rails_helper"

RSpec.describe Alarm, type: :model do
  subject { build(:alarm) }

  # ============================================================
  # アソシエーション
  # ============================================================
  describe "associations" do
    it do
      is_expected.to belong_to(:creator)
        .class_name("User")
        .with_foreign_key(:user_uuid)
        .with_primary_key(:uuid)
    end

    it do
      is_expected.to have_many(:alarm_logs)
        .with_primary_key(:uuid)
        .with_foreign_key(:alarm_uuid)
        .dependent(:destroy)
    end

    it do
      is_expected.to have_many(:alarm_memberships)
        .with_foreign_key(:alarm_uuid)
        .with_primary_key(:uuid)
        .dependent(:destroy)
    end

    it { is_expected.to have_many(:members).through(:alarm_memberships).source(:user) }
  end

  # ============================================================
  # バリデーション
  # ============================================================
  describe "validations" do
    # ---- label ----
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to validate_length_of(:label).is_at_most(255) }

    # ---- scheduled_at ----
    it { is_expected.to validate_presence_of(:scheduled_at) }

    # ---- scheduled_at_must_be_in_the_future（カスタムバリデーション）----
    describe "scheduled_at_must_be_in_the_future" do
      context "scheduled_at が未来の日時の場合" do
        it "有効である" do
          alarm = build(:alarm, scheduled_at: 1.day.from_now)
          expect(alarm).to be_valid
        end
      end

      context "scheduled_at が現在時刻以前の場合" do
        it "エラーが追加される" do
          alarm = build(:alarm, scheduled_at: 1.second.ago)
          alarm.valid?
          expect(alarm.errors[:scheduled_at]).not_to be_empty
        end
      end
    end

    # ---- started_at_must_be_before_scheduled_at（カスタムバリデーション）----
    describe "started_at_must_be_before_scheduled_at" do
      context "started_at が存在する場合" do
        context "started_at が scheduled_at より前の場合" do
          it "有効である" do
            alarm = build(:alarm, :with_started_at)
            expect(alarm).to be_valid
          end
        end

        context "started_at が scheduled_at 以降の場合" do
          it "エラーが追加される" do
            alarm = build(:alarm,
              scheduled_at: 1.day.from_now,
              started_at:   2.days.from_now
            )
            alarm.valid?
            expect(alarm.errors[:started_at]).not_to be_empty
          end
        end
      end

      context "started_at が存在しない場合" do
        it "有効である" do
          alarm = build(:alarm, started_at: nil)
          expect(alarm).to be_valid
        end
      end
    end

    # ---- started_at_within_allowed_range（カスタムバリデーション）----
    describe "started_at_within_allowed_range" do
      context "started_at が存在する場合" do
        context "started_at が現在時刻から7時間以内の場合" do
          it "有効である" do
            alarm = build(:alarm, :with_started_at)
            expect(alarm).to be_valid
          end
        end

        context "started_at が現在時刻から7時間以上前の場合" do
          it "エラーが追加される" do
            alarm = build(:alarm,
              scheduled_at: 1.day.from_now,
              started_at:   8.hours.ago
            )
            alarm.valid?
            expect(alarm.errors[:started_at]).not_to be_empty
          end
        end
      end

      context "started_at が存在しない場合" do
        it "有効である" do
          alarm = build(:alarm, started_at: nil)
          expect(alarm).to be_valid
        end
      end
    end
  end
end
