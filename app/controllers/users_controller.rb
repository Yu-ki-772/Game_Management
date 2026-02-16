class UsersController < ApplicationController
  def index
    @q = User.non_admin.excluding(current_user).ransack(search_params)

    @pagy, @users = pagy(
      @q.result.with_attached_avatar,
      limit: 15
    )

    @search_count = @pagy.count # 検索結果の表示用

    # friendshipのstatusでの条件分岐用
    user_uuids = @users.map(&:id)
    statuses = current_user.friendship_statuses_for(user_uuids)
    @pending_requests_hash = statuses[:pending_requests]
    @friendships_hash = statuses[:friendships]
  end

  def show
    @user = User.non_admin.find(params[:id]) # 管理者ユーザ以外を取得

    return if @user == current_user

    # friedshipのstatusによる条件分岐
    @pending_request_from_user = current_user.pending_request_from?(@user)
    @existing_friendship = current_user.friendship_with(@user)
  end

  private

  def search_params
    return {} unless params[:q]

    params.require(:q).permit(
      :name_cont,
      :name_eq
    )
  end
end
