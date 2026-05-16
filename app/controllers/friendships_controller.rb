class FriendshipsController < ApplicationController
  before_action :set_friendship_for_update, only: [ :update ]
  before_action :set_friendship_for_destroy, only: [ :destroy ]
  before_action :authorize_friendship, only: [ :update, :destroy ]

  def pending
    @pending = current_user.received_friendships.pending.includes(user: { avatar_attachment: :blob })
  end

  def index
    # 該当ユーザがuser側の場合とfriend側の場合の両方を取得
    sent_friendships = current_user.friendships.accepted.includes(friend: { avatar_attachment: :blob })
    received_friendships = current_user.received_friendships.accepted.includes(user: { avatar_attachment: :blob })
    @friends = sent_friendships + received_friendships
  end

  def create
    @friend = User.find(params[:friend_uuid])
    @friendship = current_user.send_friend_request(@friend)

    respond_to do |format|
      format.turbo_stream do
        if @friendship.persisted?
          flash.now[:notice] = "#{@friend.name}さんにフレンド申請を送りました"
        else
          flash.now[:alert] = "フレンド申請の送信に失敗しました"
        end
      end
      format.html do
        if @friendship.persisted?
          redirect_to users_path, notice: "#{@friend.name}さんにフレンド申請を送りました"
        else
          redirect_to users_path, alert: "フレンド申請の送信に失敗しました"
        end
      end
    end
  end

  def update
    @action_type = params[:action_type]
    # action_typeの指定により実行することが決まる
    case @action_type
    when "accept" # 申請を承認
      @friend = @friendship.user  # 申請を送ってきた相手

      if @friendship.update(status: "accepted")
        @remaining_pending_count = current_user.received_friendships.pending.count
        respond_to do |format|
          format.turbo_stream { flash.now[:notice] = "#{@friend.name}さんとフレンドになりました" }
          format.html { redirect_to pending_friendships_path, notice: "#{@friend.name}さんとフレンドになりました", status: :see_other }
        end
      else
        respond_to do |format|
          format.turbo_stream { flash.now[:alert] = "承認に失敗しました" }
          format.html { redirect_to pending_friendships_path, alert: "承認に失敗しました", status: :see_other }
        end
      end

    when "reject" # 申請を拒否
      @friend = @friendship.user

      if @friendship.destroy
        @remaining_pending_count = current_user.received_friendships.pending.count

        respond_to do |format|
          format.turbo_stream { flash.now[:notice] = "#{@friend.name}さんのフレンド申請を拒否しました" }
          format.html { redirect_to pending_friendships_path, notice: "フレンド申請を拒否しました", status: :see_other }
        end
      else
        respond_to do |format|
          format.turbo_stream { flash.now[:alert] = "拒否に失敗しました" }
          format.html { redirect_to pending_friendships_path, alert: "拒否に失敗しました", status: :see_other }
        end
      end

    else
      redirect_to pending_friendships_path, alert: "無効な操作です", status: :see_other
    end
  end

  def destroy
    friend = @friendship.partner(current_user)

    @friendship.destroy

    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = "#{friend.name}さんとのフレンド関係を解除しました"
        # 解除後の残りフレンド数をビューに渡す
        @remaining_count = current_user.friendships.accepted.count +
                   current_user.received_friendships.accepted.count
      end
      format.html { redirect_to friendships_path, notice: "フレンド関係を解除しました", status: :see_other }
    end
  end

  private

  def set_friendship_for_update
    @friendship = Friendship.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "指定されたフレンド申請が見つかりません"
    redirect_to friendships_path
  end

  def set_friendship_for_destroy
    @friendship = Friendship.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "指定されたフレンド関係が見つかりません"
    redirect_to friendships_path
  end

  # フレンド関係を操作する権限があるかの確認用
  def authorize_friendship
    # updateの場合は、申請を受け取った側（friend_uuid）であることを確認
    if action_name == "update"
      unless @friendship.friend_uuid == current_user.uuid
        flash[:alert] = "この操作は許可されていません"
        redirect_to friendships_path
      end
    # destroyの場合は、申請した側または受け取った側であることを確認
    elsif action_name == "destroy"
      unless @friendship.user_uuid == current_user.uuid || @friendship.friend_uuid == current_user.uuid
        flash[:alert] = "この操作は許可されていません"
        redirect_to friendships_path
      end
    end
  end
end