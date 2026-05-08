# app/controllers/alarm_memberships_controller.rb
class AlarmMembershipsController < ApplicationController
  before_action :set_alarm

  # フレンドをアラームに招待するときの検索用
  def search_users
    @q = User.non_admin.excluding(current_user).ransack(search_params)

    @users = @q.result
                .with_attached_avatar
                .friends_with(current_user)

    memberships = @alarm.alarm_memberships.where(user_uuid: @users.map(&:uuid))
    @invited_memberships_hash = memberships.index_by(&:user_uuid)

    render partial: "alarm_memberships/search_results",
          locals: {
            alarm: @alarm,
            users: @users,
            invited_memberships_hash: @invited_memberships_hash
          }
  end

  def create
    @membership = @alarm.alarm_memberships.new(user_uuid: params[:user_id])
    @user = User.find_by(uuid: params[:user_id])

    if @membership.save
      # 該当ユーザーのボタンを「招待済み」に差し替え
      render turbo_stream: turbo_stream.replace(
        "invite_button_#{@alarm.uuid}_#{@user.uuid}",
        partial: "alarm_memberships/invite_button",
        locals: { alarm: @alarm, user: @user, membership: @membership }
      )
    else
      head :unprocessable_entity
    end
  end

  def show
    @membership = @alarm.alarm_memberships.find_by!(id: params[:id])
    @creator    = @alarm.creator # アラームの作成者
    @members    = @alarm.alarm_memberships.includes(:user).map(&:user) # アラームの作成者以外のメンバー

    other_members  = @members.reject { |user| user == @creator }
    @display_members = other_members.first(19)
    @hidden_count    = other_members.size - @display_members.size
  end

  def destroy
    @membership = @alarm.alarm_memberships.find(params[:id])
    @user = @membership.user
    @membership.destroy!

    # 招待の解除
    # 該当ユーザーのボタンを「招待する」に差し替え
    render turbo_stream: turbo_stream.replace(
      "invite_button_#{@alarm.uuid}_#{@user.uuid}",
      partial: "alarm_memberships/invite_button",
      locals: { alarm: @alarm, user: @user, membership: nil }
    )
  end

  # メンバーとしてアラームをストップする。（アラーム作成者のアラームとは分離している。）
  def stop
    @membership = @alarm.alarm_memberships.find_by!(user_uuid: current_user.uuid)
    alarm_log = @membership.stop # stop時にalarm_logを作成

    if alarm_log

      flash[:alarm_log_id] = alarm_log.id if alarm_log
      redirect_to statistic_alarm_logs_path, notice: "アラームをストップしました", status: :see_other
    else
      redirect_to pending_alarms_path, alert: "アラームをストップできませんでした"
    end
  end

  private

  def set_alarm
    @alarm = Alarm.includes(:alarm_memberships).find(params[:alarm_id])
    raise ActiveRecord::RecordNotFound unless @alarm.accessible_by?(current_user)
  end

  # アラームへのフレンド招待時の検索用
  def search_params
    return {} unless params[:q]
    params.require(:q).permit(:name_cont)
  end
end
