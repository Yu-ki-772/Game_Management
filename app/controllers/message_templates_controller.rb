class MessageTemplatesController < ApplicationController
  before_action :set_message_template, only: [ :edit, :update, :destroy ]

  # フォームでの、既存の理由表示用
  before_action :set_existing_reasons, only: [ :new, :edit ]

  # ログイン前でも許可
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
    if user_signed_in?
      # デフォルトデータと、自分で作成したもののみ取得
      @message_templates = MessageTemplate.where(user_id: [ current_user.id, nil ])
      # 該当ユーザのブックマークの取得
      @user_bookmarks = current_user.bookmarks
                                    .where(message_template_id: @message_templates.ids)
                                    .index_by(&:message_template_id)
    else
      # デフォルトデータのみ取得
      @message_templates = MessageTemplate.where(user_id: nil)

      @user_bookmarks = {}
    end
  end

  # ブックマークした定型文の一覧表示用
  def bookmarks
    @bookmarks_message_templates = current_user.bookmarks_message_templates.order(created_at: :desc)
    # 該当ユーザのブックマークの取得
    @user_bookmarks = current_user.bookmarks
                                  .where(message_template_id: @bookmarks_message_templates.ids)
                                  .index_by(&:message_template_id)
  end

  def new
    @message_template = MessageTemplate.new
  end

  def create
    @message_template = current_user.message_templates.new(message_template_params)

    if @message_template.save
      redirect_to message_templates_path, notice: "定型文を作成しました", status: :see_other
    else
      flash.now[:alert] = "定型文を作成できませんでした"
      set_existing_reasons # フォームでの、既存の理由表示用
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @message_template.update(message_template_params)
      redirect_to message_templates_path, notice: "定型文を更新しました", status: :see_other
    else
      flash.now[:alert] = "定型文を更新できませんでした"
      set_existing_reasons # フォームでの、既存の理由表示用
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @message_template.destroy!
    redirect_to message_templates_path, notice: "定型文を削除しました", status: :see_other
  end

  private

  def set_message_template
    @message_template = current_user.message_templates.find(params[:id])
  end

  def set_existing_reasons
    @existing_reasons = MessageTemplate.existing_reasons(current_user.id)
  end

  # 許可するパラメータの定義
  def message_template_params
    params.require(:message_template).permit(:reason, :template)
  end
end
