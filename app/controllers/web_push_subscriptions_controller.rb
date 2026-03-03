class WebPushSubscriptionsController < ApplicationController

  def create
    WebPushSubscription.upsert(
      {
        endpoint:   params[:endpoint],
        user_uuid:  current_user.uuid,
        p256dh:     params[:p256dh],
        auth:       params[:auth]
      },
      unique_by: :endpoint,
      record_timestamps: true
    )

    head :ok
  end

  def destroy
    subscription = current_user.web_push_subscriptions
                                .find_by(endpoint: params[:endpoint])

    if subscription
      subscription.destroy
      head :ok
    else
      head :not_found
    end
  end
end
