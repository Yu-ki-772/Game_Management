# spec/models/diagnosis_result_spec.rb
require "rails_helper"

RSpec.describe DiagnosisResult, type: :model do
  subject { build(:diagnosis_result) }

  # ============================================================
  # アソシエーション
  # ============================================================
  describe "associations" do
    it do
      is_expected.to belong_to(:user)
        .with_primary_key(:uuid)
        .with_foreign_key(:user_uuid)
    end
  end

  # ============================================================
  # バリデーション
  # ============================================================
  describe "validations" do

    # ---- 軸スコア（4カラム共通：0〜25の範囲）----
    %i[control_score life_score quality_score consistency_score].each do |column|
      describe column do
        it { is_expected.to validate_presence_of(column) }

        it do
          is_expected.to validate_numericality_of(column)
            .is_greater_than_or_equal_to(0)
            .is_less_than_or_equal_to(25)
        end
      end
    end

    # ---- total_score（0〜100の範囲）----
    describe :total_score do
      it { is_expected.to validate_presence_of(:total_score) }

      it do
        is_expected.to validate_numericality_of(:total_score)
          .is_greater_than_or_equal_to(0)
          .is_less_than_or_equal_to(100)
      end
    end
  end
end