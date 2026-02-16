class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  #=======================================================
  # publicメソッド
  #=======================================================
  def new
    super
  end

  def create
    super do |resource|
      unless resource.persisted?
        sanitize_email_uniqueness_error(resource)
      end
    end
  end

  def edit
    super
  end

  def update
    super do |resource|
      if resource.errors.any?
        sanitize_email_uniqueness_error(resource)
      end
    end
  end

  def destroy
    super
  end

  def cancel
    super
  end

  # ominiauth用
  def build_resource(hash = {})
    hash[:uid] = User.create_unique_string
    super
  end

  # ominiauth用
  def update_resource(resource, params)
    return super if params["password"].present?

    resource.update_without_password(params.except("current_password"))
  end

  protected
  #=======================================================
  # protectedメソッド
  #=======================================================
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :attribute ])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :attribute ])
  end

  def after_sign_up_path_for(resource)
    super(resource)
  end

  def after_inactive_sign_up_path_for(resource)
    super(resource)
  end

  def after_update_path_for(resource)
    user_path(id: current_user.uuid)
  end

  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  private
  #=======================================================
  # privateメソッド
  #=======================================================

  # メールアドレスの重複エラー時に、曖昧なメッセージを表示
  def sanitize_email_uniqueness_error(resource)
    if resource.errors.details[:email].any? { |e| e[:error] == :taken } # エラー情報の中に重複エラーが含まれているか確認
      resource.errors.delete(:email) # 具体的なエラーを削除
      resource.errors.add(:base, "入力内容に誤りがあります。もう一度ご確認ください。") # 曖昧なエラーメッセージの追加
    end
  end
end
