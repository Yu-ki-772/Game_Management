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

  # spec/models/diagnosis_result_spec.rb（既存ファイルに追記）

  describe "class methods" do
    describe ".build_from_answers" do
      # 全問題に回答値 1 を設定したときのスコアを手動で計算して期待値とする。
      # reversed: false の問いは 6-1=5、reversed: true の問いは 1 になる。
      # control:     q1(5) + q2(1)                   = 6  → 6.0/10*25  = 15.0
      # life:        q3(1) + q4(1) + q5(1)            = 3  → 3.0/15*25  = 5.0
      # quality:     q6(5) + q7(1) + q8(1)            = 7  → 7.0/15*25  = 11.7
      # consistency: q9(5) + q10(1)                   = 6  → 6.0/10*25  = 15.0
      # total: 15.0 + 5.0 + 11.7 + 15.0              = 46.7
      let(:user) { build(:user) }
      let(:answers) do
        (1..10).each_with_object({}) { |i, h| h["q#{i}"] = "1" }
      end

      it "DiagnosisResult のインスタンスを返す" do
        result = DiagnosisResult.build_from_answers(user, answers)
        expect(result).to be_a(DiagnosisResult)
      end

      it "保存されていない状態で返す" do
        result = DiagnosisResult.build_from_answers(user, answers)
        expect(result).not_to be_persisted
      end

      it "control_score が正しく計算される" do
        result = DiagnosisResult.build_from_answers(user, answers)
        expect(result.control_score).to eq(15.0)
      end

      it "life_score が正しく計算される" do
        result = DiagnosisResult.build_from_answers(user, answers)
        expect(result.life_score).to eq(5.0)
      end

      it "quality_score が正しく計算される" do
        result = DiagnosisResult.build_from_answers(user, answers)
        expect(result.quality_score).to eq(11.7)
      end

      it "consistency_score が正しく計算される" do
        result = DiagnosisResult.build_from_answers(user, answers)
        expect(result.consistency_score).to eq(15.0)
      end

      it "total_score が正しく計算される" do
        result = DiagnosisResult.build_from_answers(user, answers)
        expect(result.total_score).to eq(46.7)
      end
    end
    
    describe "#axis_items" do
      it "4つの軸データを返す" do
        result = build(:diagnosis_result,
          control_score:     15.0,
          life_score:        5.0,
          quality_score:     11.7,
          consistency_score: 15.0,
          total_score:       46.7
        )
        expect(result.axis_items.length).to eq(4)
      end

      it "各軸データが icon・name・score キーを持つ" do
        result = build(:diagnosis_result,
          control_score:     15.0,
          life_score:        5.0,
          quality_score:     11.7,
          consistency_score: 15.0,
          total_score:       46.7
        )
        result.axis_items.each do |item|
          expect(item).to have_key(:icon)
          expect(item).to have_key(:name)
          expect(item).to have_key(:score)
        end
      end

      it "control_score が Float として score に設定される" do
        result = build(:diagnosis_result,
          control_score:     15,  # 整数で渡す
          life_score:        5.0,
          quality_score:     11.7,
          consistency_score: 15.0,
          total_score:       46.7
        )
        # to_f が呼ばれているため Float になっているはずである
        expect(result.axis_items.first[:score]).to be_a(Float)
      end
    end
  end

  
end
