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

    flash.now[:notice] = "通知をオンにしました"

  rescue ActiveRecord::ActiveRecordError
    flash.now[:alert] = "通知をオンにできませんでした"
  end

  def destroy
    subscription = current_user.web_push_subscriptions
                                .find_by(endpoint: params[:endpoint])

    if subscription
      subscription.destroy!
      flash.now[:notice] = "通知をオフにしました"
    else
      flash.now[:alert] = "通知の設定をオフにできませんでした"
    end

  rescue ActiveRecord::ActiveRecordError
    flash.now[:alert] = "通知をオフにできませんでした"
  end
end