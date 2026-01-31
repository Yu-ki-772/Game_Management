class BookmarksController < ApplicationController
  before_action :authenticate_user!

  def create
    @message_template = MessageTemplate.find(params[:message_template_id])
    current_user.bookmark(@message_template) # Userモデルのメソッドを使ってブックマークを作成
    @bookmark = current_user.bookmarks.find_by(message_template_id: @message_template.id)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to message_templates_path }
    end
  end

  def destroy
    @bookmark = current_user.bookmarks.find(params[:id])
    @message_template = @bookmark.message_template
    current_user.unbookmark(@message_template) # Userモデルのメソッドを使ってブックマークを削除

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to message_templates_path }
    end
  end
end
