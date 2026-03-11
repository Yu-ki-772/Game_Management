class DiagnosisResult < ApplicationRecord
  belongs_to :user, primary_key: :uuid, foreign_key: :user_uuid

  %i[control_score life_score quality_score consistency_score].each do |column|
    validates column, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 25 }
  end
  validates :total_score, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  # 診断結果の作成
  def self.build_from_answers(user, answers)
    scores = calculate_scores(answers)
    new(user: user,
        control_score:     scores[:control],
        life_score:        scores[:life],
        quality_score:     scores[:quality],
        consistency_score: scores[:consistency],
        total_score:       scores[:total])
  end

  # 結果を大まかに分けるゾーンの判定
  def zone
    case total_score
    when 80.. then "green"
    when 55.. then "yellow"
    when 30.. then "orange"
    else           "red"
    end
  end

  # ゾーンの判定メソッド群
  def green?  = zone == "green"
  def yellow? = zone == "yellow"
  def orange? = zone == "orange"
  def red?    = zone == "red"


  # 軸ごとに表示するものを決める
  def axis_items
    [
      { icon: "🎮", name: "コントロール感",   score: control_score.to_f    },
      { icon: "🌿", name: "生活統合度",       score: life_score.to_f        },
      { icon: "⭐", name: "プレイの質",       score: quality_score.to_f     },
      { icon: "🎯", name: "自己認識の一致度", score: consistency_score.to_f }
    ]
  end

  private





  # 質問ごとの軸や配転基準
  QUESTIONS = [
    { key: "q1",  axis: :control,     reversed: false },
    { key: "q2",  axis: :control,     reversed: true  },
    { key: "q3",  axis: :life,        reversed: true  },
    { key: "q4",  axis: :life,        reversed: true  },
    { key: "q5",  axis: :life,        reversed: true  },
    { key: "q6",  axis: :quality,     reversed: false },
    { key: "q7",  axis: :quality,     reversed: true  },
    { key: "q8",  axis: :quality,     reversed: true  },
    { key: "q9",  axis: :consistency, reversed: false },
    { key: "q10", axis: :consistency, reversed: true  },
  ].freeze

  AXIS_MAX_SCORE = { control: 10, life: 15, quality: 15, consistency: 10 }.freeze

  # スコアの算出
  def self.calculate_scores(answers)
    # reversed: true（ネガティブな問い）はそのまま、false（ポジティブな問い）は 6-value で反転
    raw_scores = QUESTIONS.each_with_object(Hash.new(0)) do |question, acc|
      answer_value = answers[question[:key]].to_i
      acc[question[:axis]] += question[:reversed] ? answer_value : (6 - answer_value)
    end
    axis_scores = raw_scores.to_h { |axis, score| [axis, (score.to_f / AXIS_MAX_SCORE[axis] * 25).round(1)] }
    axis_scores.merge(total: axis_scores.values.sum.round(1))
  end
end