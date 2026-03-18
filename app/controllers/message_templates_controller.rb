class MessageTemplatesController < ApplicationController
  before_action :set_message_template, only: [ :edit, :update, :destroy ]
  before_action :set_existing_reasons, only: [ :new, :edit ]

  def index
    base_query = MessageTemplate.where(user_uuid: [ current_user.uuid, nil ])
    @message_templates = base_query.order(reason: :asc, created_at: :desc)
    @user_bookmarks = current_user.bookmarks
                                  .where(message_template_id: @message_templates.ids)
                                  .index_by(&:message_template_id)
  end

  def bookmarks
    @bookmarks_message_templates = current_user.bookmarks_message_templates
                                               .order(created_at: :desc)
    @user_bookmarks = current_user.bookmarks
                                  .where(message_template_id: @bookmarks_message_templates.ids)
                                  .index_by(&:message_template_id)

    # 検索がなくなったので固定メッセージに統一
    @empty_message = "まだブックマークがありません"
    @empty_description = "定型文一覧からブックマークを追加してみましょう"
  end

  def manage
    base_query = MessageTemplate.where(user_uuid: [ current_user.uuid, nil ])
    @message_templates = base_query.order(reason: :asc, created_at: :desc)
    @user_bookmarks = current_user.bookmarks
                                  .where(message_template_id: @message_templates.ids)
                                  .index_by(&:message_template_id)
  end

  def new
    @message_template = MessageTemplate.new
  end

  def create
    @message_template = current_user.message_templates.new(message_template_params)

    if @message_template.save
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "定型文を作成しました"
          load_templates_list_data
        end
        format.html { redirect_to message_templates_path, notice: "定型文を作成しました", status: :see_other }
      end
    else
      flash.now[:alert] = "定型文を作成できませんでした"
      set_existing_reasons
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @message_template.update(message_template_params)
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "定型文を更新しました"
          load_templates_list_data
        end
        format.html { redirect_to message_templates_path, notice: "定型文を更新しました", status: :see_other }
      end
    else
      flash.now[:alert] = "定型文を更新できませんでした"
      set_existing_reasons
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @message_template.destroy!

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = "定型文を削除しました"
        load_templates_list_data
      end
      format.html { redirect_to manage_message_templates_path, notice: "定型文を削除しました", status: :see_other }
    end
  end

  private

  def set_message_template
    @message_template = current_user.message_templates.find(params[:id])
  end

  def set_existing_reasons
    @existing_reasons = MessageTemplate.existing_reasons(current_user.uuid)
  end

  def message_template_params
    params.require(:message_template).permit(:reason, :template)
  end

  def load_templates_list_data
    base_query = MessageTemplate.where(user_uuid: [ current_user.uuid, nil ])
    @message_templates = base_query.order(reason: :asc, created_at: :desc)
    @user_bookmarks = current_user.bookmarks
                                  .where(message_template_id: @message_templates.ids)
                                  .index_by(&:message_template_id)

    @bookmarks_message_templates = current_user.bookmarks_message_templates
                                               .order(created_at: :desc)
    @bookmarks_user_bookmarks = current_user.bookmarks
                                            .where(message_template_id: @bookmarks_message_templates.ids)
                                            .index_by(&:message_template_id)
  end
end
