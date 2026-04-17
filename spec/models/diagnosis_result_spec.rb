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
    # モデルでは %i[].each でまとめて定義されているが、
    # テストは個別に書くことでどのカラムが壊れているかを明確に特定できる。
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

    describe :total_score do
      it { is_expected.to validate_presence_of(:total_score) }

      it do
        is_expected.to validate_numericality_of(:total_score)
          .is_greater_than_or_equal_to(0)
          .is_less_than_or_equal_to(100)
      end
    end
  end

  # ============================================================
  # インスタンスメソッド
  # ============================================================
  describe "instance methods" do
    # ----------------------------------------------------------
    # #zone
    # ----------------------------------------------------------
    describe "#zone" do
      # 境界値を中心に検証

      context "total_score が 80 以上の場合" do
        it "境界値の 80 のとき green を返す" do
          result = build(:diagnosis_result, total_score: 80)
          expect(result.zone).to eq("green")
        end

        it "100 のとき green を返す" do
          result = build(:diagnosis_result, total_score: 100)
          expect(result.zone).to eq("green")
        end
      end

      context "total_score が 55 以上 79 以下の場合" do
        it "境界値の 55 のとき yellow を返す" do
          result = build(:diagnosis_result, total_score: 55)
          expect(result.zone).to eq("yellow")
        end

        it "境界値の 79 のとき yellow を返す" do
          result = build(:diagnosis_result, total_score: 79)
          expect(result.zone).to eq("yellow")
        end
      end

      context "total_score が 30 以上 54 以下の場合" do
        it "境界値の 30 のとき orange を返す" do
          result = build(:diagnosis_result, total_score: 30)
          expect(result.zone).to eq("orange")
        end

        it "境界値の 54 のとき orange を返す" do
          result = build(:diagnosis_result, total_score: 54)
          expect(result.zone).to eq("orange")
        end
      end

      context "total_score が 29 以下の場合" do
        it "境界値の 29 のとき red を返す" do
          result = build(:diagnosis_result, total_score: 29)
          expect(result.zone).to eq("red")
        end
      end
    end

    describe "#green?" do
      it "zone が green のとき true を返す" do
        expect(build(:diagnosis_result, total_score: 80).green?).to be true
      end

      it "zone が green でないとき false を返す" do
        expect(build(:diagnosis_result, total_score: 79).green?).to be false
      end
    end

    describe "#yellow?" do
      it "zone が yellow のとき true を返す" do
        expect(build(:diagnosis_result, total_score: 55).yellow?).to be true
      end

      it "zone が yellow でないとき false を返す" do
        expect(build(:diagnosis_result, total_score: 54).yellow?).to be false
      end
    end

    describe "#orange?" do
      it "zone が orange のとき true を返す" do
        expect(build(:diagnosis_result, total_score: 30).orange?).to be true
      end

      it "zone が orange でないとき false を返す" do
        expect(build(:diagnosis_result, total_score: 29).orange?).to be false
      end
    end

    describe "#red?" do
      it "zone が red のとき true を返す" do
        expect(build(:diagnosis_result, total_score: 29).red?).to be true
      end

      it "zone が red でないとき false を返す" do
        expect(build(:diagnosis_result, total_score: 30).red?).to be false
      end
    end

    # ----------------------------------------------------------
    # #axis_items
    # ----------------------------------------------------------
    describe "#axis_items" do
      let(:result) do
        build(:diagnosis_result,
          control_score:     25.0,
          life_score:        5.0,
          quality_score:     15.0,
          consistency_score: 25.0,
          total_score:       70.0
        )
      end

      it "4つの軸データを返す" do
        expect(result.axis_items.length).to eq(4)
      end

      it "各軸データが icon・name・score キーを持つ" do
        result.axis_items.each do |item|
          expect(item).to have_key(:icon)
          expect(item).to have_key(:name)
          expect(item).to have_key(:score)
        end
      end

      it "control_score が Float として score に設定される" do
        result = build(:diagnosis_result,
          control_score:     25,
          life_score:        5.0,
          quality_score:     15.0,
          consistency_score: 25.0,
          total_score:       70.0
        )
        expect(result.axis_items.first[:score]).to be_a(Float)
      end
    end
  end

  # ============================================================
  # クラスメソッド
  # ============================================================
  describe "class methods" do
    describe ".build_from_answers" do
      # ↓ 計算結果（全問に 1 と回答した場合）
      # reversed: false の問いは 6-1=5、reversed: true の問いは 1 になる。
      # control:     q1(5)                        = 5  → 5.0/5*25   = 25.0
      # life:        q2(1) + q3(1) + q4(1)        = 3  → 3.0/15*25  = 5.0
      # quality:     q5(5) + q6(1)                = 6  → 6.0/10*25  = 15.0
      # consistency: q7(5) + q8(5)                = 10 → 10.0/10*25 = 25.0
      # total:       25.0 + 5.0 + 15.0 + 25.0    = 70.0
      let(:user) { build(:user) }
      # 全て１と回答
      let(:answers) do
        (1..8).each_with_object({}) { |i, h| h["q#{i}"] = "1" }
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
        expect(result.control_score).to eq(25.0)
      end

      it "life_score が正しく計算される" do
        result = DiagnosisResult.build_from_answers(user, answers)
        expect(result.life_score).to eq(5.0)
      end

      it "quality_score が正しく計算される" do
        result = DiagnosisResult.build_from_answers(user, answers)
        expect(result.quality_score).to eq(15.0)
      end

      it "consistency_score が正しく計算される" do
        result = DiagnosisResult.build_from_answers(user, answers)
        expect(result.consistency_score).to eq(25.0)
      end

      it "total_score が正しく計算される" do
        result = DiagnosisResult.build_from_answers(user, answers)
        expect(result.total_score).to eq(70.0)
      end
    end
  end
end
