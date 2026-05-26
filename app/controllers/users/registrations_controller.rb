class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  #=======================================================
  # publicメソッド
  #=======================================================

  def create
    super do |resource|
      if resource.persisted?
        flash[:show_push_notification_modal] = true
      else
        sanitize_email_uniqueness_error(resource)
      end
    end
  end


  def update
    super do |resource|
      if resource.errors.any?
        sanitize_email_uniqueness_error(resource)
      end
    end
  end



  protected
  #=======================================================
  # protectedメソッド
  #=======================================================
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :description, :avatar ])
  end



  def after_update_path_for(resource)
    user_path(id: current_user.uuid)
  end

  def update_resource(resource, params)
    # アバターがパラメータに含まれている場合のみリサイズ処理を行う
    if params[:avatar].present?
      return false unless resource.attach_resized_avatar(params[:avatar])

      params = params.except(:avatar)
    end

    return super if params["password"].present?

    resource.update_without_password(params.except("current_password"))
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
