class MessageTemplatesController < ApplicationController
  before_action :set_message_template, only: [ :edit, :update, :destroy ]

  # フォームでの、既存の理由表示用
  before_action :set_existing_reasons, only: [ :new, :edit ]

  def index
    # 基本となるクエリ（デフォルトデータと、自分で作成したものを取得）
    base_query = MessageTemplate.where(user_uuid: [ current_user.uuid, nil ])

    # 検索
    @q = base_query.ransack(search_params)
    @message_templates = @q.result.order(reason: :asc, created_at: :desc)

    @available_reasons = base_query.distinct.pluck(:reason).sort

    # 該当ユーザのブックマークの取得
    @user_bookmarks = current_user.bookmarks
                                  .where(message_template_id: @message_templates.ids)
                                  .index_by(&:message_template_id)
  end

  # ブックマークした定型文の一覧表示用
  def bookmarks
    # 基本クエリ: ブックマーク済みの定型文
    base_query = current_user.bookmarks_message_templates

    # 検索
    @q = base_query.ransack(search_params)
    @bookmarks_message_templates = @q.result.order(created_at: :desc)

    @available_reasons = base_query.distinct.pluck(:reason).sort

    # 該当ユーザのブックマークの取得
    @user_bookmarks = current_user.bookmarks
                                  .where(message_template_id: @bookmarks_message_templates.ids)
                                  .index_by(&:message_template_id)

    @empty_message = params[:q].present? ? "ブックマークが見つかりませんでした" : "まだブックマークがありません"
    @empty_description = params[:q].present? ? "検索条件を変更してお試しください" : "定型文一覧からブックマークを追加してみましょう"
  end

  def new
    @message_template = MessageTemplate.new
  end

  def create
    @message_template = current_user.message_templates.new(message_template_params)

    if @message_template.save
      respond_to do |format|
        format.turbo_stream do
          load_templates_list_data  # リスト再描画に必要なデータを取得
        end
        format.html { redirect_to message_templates_path, notice: "定型文を作成しました", status: :see_other }
      end
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
      respond_to do |format|
        format.turbo_stream do
          load_templates_list_data  # リスト再描画に必要なデータを取得
        end
        format.html { redirect_to message_templates_path, notice: "定型文を更新しました", status: :see_other }
      end
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
    @existing_reasons = MessageTemplate.existing_reasons(current_user.uuid)
  end

  # 許可するパラメータの定義
  def message_template_params
    params.require(:message_template).permit(:reason, :template)
  end

  # 検索パラメータ
  def search_params
    return {} unless params[:q]

    params.require(:q).permit(
      :template_or_reason_cont,  # テキスト検索（本文 or カテゴリー）
      :reason_eq,       # カテゴリーでの完全一致検索
    )
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
