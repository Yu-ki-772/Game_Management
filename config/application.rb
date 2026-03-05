require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Myapp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # 外部ホストにリダイレクトすることからの保護
    config.action_controller.raise_on_open_redirects = true

    config.action_cable.mount_path = nil

    # デフォルトのロケールを日本語に設定
    config.i18n.default_locale = :ja

    # タイムゾーンを日本時間に設定
    config.time_zone = "Tokyo"

    # simple_calenderの最初の曜日が「日」になるように
    config.beginning_of_week = :sunday

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # active_jobのキューアダプターをgood_jobに設定
    config.active_job.queue_adapter = :good_job

    # アップロード時にリサイズして保存する設計のため無効化
    config.active_storage.track_variants = false
  end
end
