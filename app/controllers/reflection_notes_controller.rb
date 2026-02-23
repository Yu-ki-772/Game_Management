class ReflectionNotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reflection_note, only: %i[edit update destroy]

  def index
    base_query = current_user.reflection_notes

    base_query = base_query.by_period(params[:period]) if params[:period].present?

    @q = base_query.ransack(search_params)
    @reflection_notes = @q.result.includes(:tags).order(created_at: :desc)

    @all_tags = current_user.tags.order(:name)
  end

  def new
    @reflection_note = ReflectionNote.new
    @existing_tags   = current_user.existing_tags
  end

  def create
    @reflection_note = current_user.reflection_notes.build(reflection_note_params)

    if @reflection_note.save
      @reflection_note.sync_tags(
        tag_ids:       params[:tag_ids],
        new_tag_names: params[:new_tag_names]
      )
      redirect_to reflection_notes_path, notice: "振り返りメモを作成しました。"
    else
      @existing_tags = current_user.existing_tags
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @existing_tags = current_user.existing_tags
  end

  def update
    if @reflection_note.update(reflection_note_params)
      @reflection_note.sync_tags(
        tag_ids:       params[:tag_ids],
        new_tag_names: params[:new_tag_names]
      )
      redirect_to reflection_notes_path, notice: "振り返りメモを更新しました。"
    else
      @existing_tags = current_user.existing_tags
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @reflection_note.destroy
    redirect_to reflection_notes_path, notice: "振り返りメモを削除しました。"
  end

  private

  def set_reflection_note
    @reflection_note = current_user.reflection_notes.find(params[:id])
  end

  def reflection_note_params
    params.require(:reflection_note).permit(:title, :body, :reflection_type)
  end

  def search_params
    return {} unless params[:q]

    permitted = params.require(:q).permit(
      :title_or_body_cont,
      :reflection_type_eq,
      :tags_id_eq
    )

    # 検索文字列が長すぎる場合は無視
    if permitted[:title_or_body_cont].to_s.length > 100
      permitted[:title_or_body_cont] = nil
    end

    permitted
  end
end
