# app/helpers/application_helper.rb
module ApplicationHelper
  def default_meta_tags
    {
      site: "Game Exit",
      charset: "utf-8",
      description: "複数のアプローチでゲーム時間管理をサポート。",
      title: "ゲーム時間管理",
      separator: " - ",
      keywords: "ゲーム,時間管理",
      canonical: ENV.fetch("APP_URL", "http://localhost:3000"),
      og: {
        site_name: "Game Exit",
        description: "複数のアプローチでゲーム時間管理をサポート。",
        title: "ゲーム時間管理",
        type: "website",
        url: ENV.fetch("APP_URL", "http://localhost:3000"),
        image: image_url("ogp.jpg", only_path: false), # 絶対パスで設定
        "image:alt" => "Game Exit - ゲーム時間管理",
        locale: "ja_JP"
      },
      twitter: {
        card: "summary_large_image",
        description: "複数のアプローチでゲーム時間管理をサポート。",
        title: "ゲーム時間管理",
        image: image_url("ogp.jpg", only_path: false), # 絶対パスで設定
        "image:alt" => "Game Exit - ゲーム時間管理"
      }
    }
  end

  # Xでシェアするボタン用
  def x_share_url
    base_url = "https://x.com/intent/tweet"

    # シェアするもの
    share_data = {
      url: ENV.fetch("APP_URL", "http://localhost:3000"),
      hashtags: "ゲーム,時間管理,GameExit"
    }
    "#{base_url}?#{share_data.to_query}"
  end


  # コントローラー名かパスのいずれかに一致する場合の
  # フッタのメニューの色
  def nav_link_class_for(controllers: [], paths: [])
    is_active = controllers.include?(controller_name) ||
                paths.any? { |path| current_page?(path) }

    if is_active
      "#{active_state_classes} px-3 py-2 rounded-md text-sm"
    else
      "text-gray-500 dark:text-gray-400
        hover:text-gray-900 dark:hover:text-gray-100
        px-3 py-2 rounded-md text-sm font-medium transition-colors"
    end
  end

  # ドロップダウンのトリガーのボタン
  def dropdown_button_class(paths)
    is_active = paths.any? { |path| current_page?(path) }
    base = "px-3 py-2 rounded-md text-sm font-medium transition-colors flex items-center gap-1"

    if is_active
      "#{base} #{active_state_classes}"
    else
      "#{base} text-gray-500 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100"
    end
  end

  # ドロップダウン内の各メニュー項目用
  def dropdown_item_class(path)
    # py-3.5 がスマホ向け（タップしやすい高さ）、sm:py-2.5 がデスクトップ向け
    base = "block px-4 py-3.5 lg:py-2.5 text-sm"

    if current_page?(path)
      "#{base} #{active_state_classes}"
    else
      "#{base} text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-900 transition-colors"
    end
  end

  # ajax処理対応のフラッシュメッセージ用
  def render_turbo_stream_flash_messages
    turbo_stream.prepend "flash_messages", partial: "shared/flash"
  end

  # プレイ時間の表示
  def format_play_minutes(minutes)
    return "#{minutes}分" if minutes <= 60

    hours = minutes / 60    # 時間（切り捨て）
    mins  = minutes % 60    # 残りの分

    if mins.zero?
      "#{hours}時間"
    else
      "#{hours}時間#{mins}分"
    end
  end

  private

  # メニューのアクティブ状態のカラークラスを一元管理
  def active_state_classes
    "text-emerald-600 dark:text-emerald-400 font-semibold"
  end
end
