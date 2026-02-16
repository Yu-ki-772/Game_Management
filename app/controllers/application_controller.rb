class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  # 「ログイン時のみ許可」をデフォルトに設定
  before_action :authenticate_user!

  before_action :configure_permitted_parameters, if: :devise_controller?

  include Pagy::Method # ページネーション用

  protected

  def configure_permitted_parameters
    # サインアップ時にnameを許可
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :avatar, :name, :description ])
  end
end
