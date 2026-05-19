# spec/helpers/diagnosis_results_helper_spec.rb
require "rails_helper"

RSpec.describe DiagnosisResultsHelper do
  describe "#zone_label" do
    context "zone が green のとき" do
      it "グリーンゾーンのラベルを返す" do
        result = build(:diagnosis_result, total_score: 80)
        expect(helper.zone_label(result)).to eq("グリーンゾーン｜充実している")
      end
    end

    context "zone が yellow のとき" do
      it "イエローゾーンのラベルを返す" do
        result = build(:diagnosis_result, total_score: 55)
        expect(helper.zone_label(result)).to eq("イエローゾーン｜調整の余地あり")
      end
    end

    context "zone が orange のとき" do
      it "オレンジゾーンのラベルを返す" do
        result = build(:diagnosis_result, total_score: 30)
        expect(helper.zone_label(result)).to eq("オレンジゾーン｜要注意")
      end
    end

    context "zone が red のとき" do
      it "レッドゾーンのラベルを返す" do
        result = build(:diagnosis_result, total_score: 29)
        expect(helper.zone_label(result)).to eq("レッドゾーン｜要サポート")
      end
    end
  end

  describe "#x_share_url_for_diagnosis" do
    def decoded_text(result)
      uri = URI.parse(helper.x_share_url_for_diagnosis(result))
      URI.decode_www_form(uri.query).to_h["text"]
    end

    context "zone が green のとき" do
      it "🟢 と total_score を含む" do
        result = build(:diagnosis_result, total_score: 80)
        text = decoded_text(result)
        expect(text).to include("🟢")
        expect(text).to include("80")
      end
    end

    context "zone が yellow のとき" do
      it "🟡 と total_score を含む" do
        result = build(:diagnosis_result, total_score: 55)
        text = decoded_text(result)
        expect(text).to include("🟡")
        expect(text).to include("55")
      end
    end

    context "zone が orange のとき" do
      it "🟠 と total_score を含む" do
        result = build(:diagnosis_result, total_score: 30)
        text = decoded_text(result)
        expect(text).to include("🟠")
        expect(text).to include("30")
      end
    end

    context "zone が red のとき" do
      it "絵文字が含まれない（バグ）" do
        result = build(:diagnosis_result, total_score: 29)
        text = decoded_text(result)
        expect(text).not_to include("🟢")
        expect(text).not_to include("🟡")
        expect(text).not_to include("🟠")
        expect(text).to include("29")
      end
    end
  end
end