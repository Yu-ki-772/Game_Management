class WebPushSubscriptionsController < ApplicationController
  # 購読情報をDBに保存する
  # upsertを使うのは、同一デバイスで再購読した際にp256dhやauthが更新される場合があるため
  def create
    WebPushSubscription.upsert(
      {
        endpoint:  params[:endpoint],
        user_uuid: current_user.uuid,
        p256dh:    params[:p256dh],
        auth:      params[:auth]
      },
      unique_by: %i[endpoint user_uuid],
      record_timestamps: true
    )
  end

  # 購読情報をDBから削除する
  def destroy
    current_user.web_push_subscriptions
                .find_by(endpoint: params[:endpoint])
                &.destroy!
  end
end