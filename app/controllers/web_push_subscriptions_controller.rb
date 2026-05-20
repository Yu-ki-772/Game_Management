class WebPushSubscriptionsController < ApplicationController
  def create
    WebPushSubscription.upsert(
      {
        endpoint:  params[:endpoint],
        user_uuid: current_user.uuid,
        p256dh:    params[:p256dh],
        auth:      params[:auth]
      },
      unique_by: :endpoint,
      record_timestamps: true
    )
  end

  def destroy
    current_user.web_push_subscriptions
                .find_by(endpoint: params[:endpoint])
                &.destroy!
  end
end