class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  # 「ログイン時のみ許可」をデフォルトに設定
  before_action :authenticate_user!

  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :set_pending_friendship_count
  before_action :set_stoppable_alarms_count, if: :user_signed_in?

  include Pagy::Method # ページネーション用

  protected

  def configure_permitted_parameters
    # サインアップ時にnameを許可
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :avatar, :name, :description ])
  end

  # フッタに表示する「受け取っているフレンド申請の数」を取得
  def set_pending_friendship_count
    return unless current_user
    @pending_friendship_count = current_user.received_friendships.pending.count
  end

  def set_stoppable_alarms_count
    @stoppable_alarms_count = current_user.member_alarms
                              .stoppable_now
                              .not_stopped_by(current_user)
                              .count
  end
end
