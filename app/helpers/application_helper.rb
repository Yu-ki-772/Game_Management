# app/helpers/application_helper.rb
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

  def nav_link_class(path)
    if current_page?(path)
      "#{active_state_classes} px-3 py-2 rounded-md text-sm font-medium"
    else
      "text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 hover:text-emerald-600 dark:hover:text-emerald-400 px-3 py-2 rounded-md text-sm font-medium transition"
    end
  end

  # ドロップダウンのトリガーのボタン
  def dropdown_button_class(paths)
    is_active = paths.any? { |path| current_page?(path) }
    base = "px-3 py-2 rounded-md text-sm font-medium transition flex items-center gap-1"

    if is_active
      "#{base} #{active_state_classes}"
    else
      "#{base} text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 hover:text-emerald-600 dark:hover:text-emerald-400"
    end
  end

  # ドロップダウン内の各メニュー項目用
  def dropdown_item_class(path)
    base = "block px-4 py-2 text-sm"

    if current_page?(path)
      "#{base} #{active_state_classes} font-medium"
    else
      "#{base} text-gray-700 dark:text-gray-200 hover:bg-gray-50 dark:hover:bg-gray-700 transition"
    end
  end

  private

  # メニューのアクティブ状態のカラークラスを一元管理
  def active_state_classes
    "text-emerald-600 dark:text-emerald-400 bg-emerald-50 dark:bg-emerald-900/30"
  end
end