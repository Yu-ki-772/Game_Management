class BookmarksController < ApplicationController
  before_action :authenticate_user!

  def create
    message_template = MessageTemplate.find(params[:message_template_id])
    current_user.bookmark(message_template) # Userモデルのメソッドを使ってブックマークを作成
    redirect_to message_templates_path, notice: "ブックマークしました", status: :see_other
  end

  def destroy
    message_template = current_user.bookmarks.find(params[:id]).message_template
    current_user.unbookmark(message_template) # Userモデルのメソッドを使ってブックマークを削除
    redirect_to message_templates_path, notice: "ブックマークを外しました", status: :see_other
  end
end
