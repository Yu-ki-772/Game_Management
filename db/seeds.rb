# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# リセット処理
MessageTemplate.destroy_all


templates_data = {
  "予定が急に入った場合" => [
    "申し訳ありません、急用が入ってしまったので今日はここで失礼します。",
    "急な用事ができちゃったので今日はここで抜けますね、ごめんね。"
  ],
  "終了の予定時間になった場合" => [
    "すみません、時間になったので今日はここで失礼します。またぜひお願いします！",
    "お、時間だ！今日はここで抜けるね！またやろ〜！",
    "家庭の事情により、本日は欠席いたします。"
  ],
  "なんとなくやめたくなった場合" => [
    "ちょっと抜けなきゃなので、今日はここまでにします！また遊ぼう！",
    "そろそろ落ちます〜！また誘ってください！"
  ],
  "ゲームの進行が悪くて気まずくなった場合" => [
    "ごめん、今日はちょっと調子悪いので抜けます！また次回リベンジさせて…！",
    "集中できなくなってきたので、今日はここで落ちます！"
  ]
}

templates_data.each do |reason, templates|
  templates.each do |template|
    MessageTemplate.create!(reason: reason, template: template)
  end
end

# 確認用のログを出力
puts "#{MessageTemplate.count}件の定型文を作成しました。"
