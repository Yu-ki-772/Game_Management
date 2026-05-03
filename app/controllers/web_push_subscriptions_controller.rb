class WebPushSubscriptionsController < ApplicationController
  def create
    WebPushSubscription.subscribe(
      endpoint: params[:endpoint],
      user:     current_user,
      p256dh:   params[:p256dh],
      auth:     params[:auth]
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
