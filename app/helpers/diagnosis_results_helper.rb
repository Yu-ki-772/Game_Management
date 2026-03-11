# app/helpers/diagnosis_results_helper.rb

module DiagnosisResultsHelper
  ZONE_DATA = {
    "green" => {
      label:    "グリーンゾーン｜充実している",
      headline: "ゲームとの関係は良好です 🎉",
      message:  "全体的にバランスの取れたゲームライフを送れています。",
      bg:       "bg-emerald-50 dark:bg-emerald-900/20",
      border:   "border-emerald-100 dark:border-emerald-800",
      text:     "text-emerald-600 dark:text-emerald-400",
      dot:      "bg-emerald-400",
      bar:      "bg-emerald-400 dark:bg-emerald-500"
    },
    "yellow" => {
      label:    "イエローゾーン｜調整の余地あり",
      headline: "一部の軸で調整の余地があります",
      message:  "おおむね問題ないですが、スコアが低めの軸に少し意識を向けてみましょう。小さな改善が、ゲームライフ全体の充実につながります。",
      bg:       "bg-amber-50 dark:bg-amber-900/20",
      border:   "border-amber-100 dark:border-amber-800",
      text:     "text-amber-600 dark:text-amber-400",
      dot:      "bg-amber-400",
      bar:      "bg-amber-400 dark:bg-amber-500"
    },
    "orange" => {
      label:    "オレンジゾーン｜要注意",
      headline: "複数の生活領域に影響が出ています",
      message:  "ゲームが睡眠・勉強・人間関係にじわじわと影響を与えている可能性があります。まず「1日の終了時刻を決める」など、小さなルールから始めてみましょう。",
      bg:       "bg-orange-50 dark:bg-orange-900/20",
      border:   "border-orange-100 dark:border-orange-800",
      text:     "text-orange-600 dark:text-orange-400",
      dot:      "bg-orange-400",
      bar:      "bg-orange-400 dark:bg-orange-500"
    },
    "red" => {
      label:    "レッドゾーン｜要サポート",
      headline: "専門家への相談も選択肢のひとつです",
      message:  "この診断はゲーム障害の医学的な判定ではありませんが、スコアからはゲームとの関係で日常生活への負担が大きい可能性が示されています。一人で抱え込まず、信頼できる大人や専門家に話してみることを検討してください。",
      bg:       "bg-red-50 dark:bg-red-900/20",
      border:   "border-red-100 dark:border-red-900",
      text:     "text-red-600 dark:text-red-400",
      dot:      "bg-red-400",
      bar:      "bg-red-400 dark:bg-red-500"
    }
  }.freeze

  # result を受け取って表示用データを返すヘルパーメソッド群
  def zone_label(result)        = ZONE_DATA[result.zone][:label]
  def zone_headline(result)     = ZONE_DATA[result.zone][:headline]
  def zone_message(result)      = ZONE_DATA[result.zone][:message]
  def zone_bg_class(result)     = ZONE_DATA[result.zone][:bg]
  def zone_border_class(result) = ZONE_DATA[result.zone][:border]
  def zone_text_class(result)   = ZONE_DATA[result.zone][:text]
  def zone_dot_class(result)    = ZONE_DATA[result.zone][:dot]
  def zone_bar_class(result)    = ZONE_DATA[result.zone][:bar]
end