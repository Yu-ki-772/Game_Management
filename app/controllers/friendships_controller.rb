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

    # 受け取っているフレンド申請の数
    @pending_count = current_user.received_friendships.pending.count
  end

  def create
    friend = User.find(params[:friend_id])

    if current_user.send_friend_request(friend)
      flash[:notice] = "#{friend.name}さんにフレンド申請を送りました"
    else
      flash[:alert] = "フレンド申請の送信に失敗しました"
    end

    redirect_to users_path
  end

  def update
    # action_typeの指定により実行することが決まる
    case params[:action_type]
    when "accept" # 申請を承認
      # Userモデルのaccept_friend_requestメソッドを使います
      if @friendship.update(status: "accepted")
        flash[:notice] = "#{@friendship.user.name}さんとフレンドになりました"

      else
        flash[:alert] = "承認に失敗しました"

      end

      redirect_to pending_friendships_path

    when "reject" # 申請を拒否
      if @friendship.destroy
        flash[:notice] = "フレンド申請を拒否しました"
      else
        flash[:alert] = "拒否に失敗しました"
      end
      redirect_to pending_friendships_path

    else
      flash[:alert] = "無効な操作です"
      redirect_to pending_friendships_path
    end
  end

  def destroy
    friend = @friendship.partner(current_user)

    @friendship.destroy

    flash[:notice] = "#{friend.name}さんとのフレンド関係を解除しました"
    redirect_to friendships_path
  end

  private

  def set_friendship_for_update
    @friendship = current_user.received_friendships.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "指定されたフレンド申請が見つかりません"
    redirect_to friendships_path
  end

  def set_friendship_for_destroy
    @friendship = Friendship.find(params[:id])
    unless @friendship.user_id == current_user.id || @friendship.friend_id == current_user.id
      flash[:alert] = "この操作は許可されていません"
      redirect_to friendships_path
    end
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "指定されたフレンド関係が見つかりません"
    redirect_to friendships_path
  end

  # フレンド関係を操作する権限があるかの確認用
  def authorize_friendship
    # updateの場合は、申請を受け取った側（friend_id）であることを確認
    if action_name == "update"
      unless @friendship.friend_id == current_user.id
        flash[:alert] = "この操作は許可されていません"
        redirect_to friendships_path
      end
    # destroyの場合は、申請した側または受け取った側であることを確認
    elsif action_name == "destroy"
      unless @friendship.user_id == current_user.id || @friendship.friend_id == current_user.id
        flash[:alert] = "この操作は許可されていません"
        redirect_to friendships_path
      end
    end
  end
end
