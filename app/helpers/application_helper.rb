module ApplicationHelper
  def default_meta_tags
    {
      site: "Game Exit",
      reverse: true,
      charset: "utf-8",
      title: "ゲーム時間管理サービス",
      description: "決めた時間にゲームをやめることをサポートします。",
      separator: "|",
      keywords: "ゲーム,時間管理",
      canonical: ENV.fetch("APP_URL", "http://localhost:3000"),
      og: {
        site_name: "Game Exit",
        title: "ゲーム時間管理サービス",
        description: "決めた時間にゲームをやめることをサポートします。※OGP画像はAIで生成したものです。",
        type: "website",
        url: ENV.fetch("APP_URL", "http://localhost:3000"),
        image: image_url("ogp.jpg", only_path: false), # 絶対パスで設定
        locale: "ja_JP"
      },
      twitter: {
        card: "summary_large_image",
        title: "ゲーム時間管理サービス",
        description: "決めた時間にゲームをやめることをサポートします。※OGP画像はAIで生成したものです。",
        image: image_url("ogp.jpg", only_path: false) # 絶対パスで設定
      }
    }
  end

  # Xでシェアするボタン用
  def x_share_url
    base_url = "https://x.com/intent/tweet"

    # シェアするもの
    share_data = {
      text: "ゲーム時間管理サービス",
      url: ENV.fetch("APP_URL", "http://localhost:3000"),
      hashtags: "ゲーム,時間管理,GameExit"
    }

    "#{base_url}?#{share_data.to_query}"
  end
end
