# app/controllers/web_push_subscriptions_controller.rb

class WebPushSubscriptionsController < ApplicationController
  # 購読情報をDBに保存する
  # upsertを使うのは以下の理由による
  # - 複数タブで同時に購読リクエストが送られた場合の重複エラーを防ぐため
  # - ブラウザ側の購読削除が失敗してブラウザ側の購読が残っていて、かつ再購読しようとした場合に、作成ではなく更新を実行することで、ユニーク制約に引っ掛からないようにするため
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

    flash.now[:notice] = "通知をオンにしました"
  rescue
    flash.now[:alert] = "通知をオンにできませんでした"
  end

  # 購読情報をDBから削除する
  def destroy
    current_user.web_push_subscriptions
                .find_by(endpoint: params[:endpoint])
                &.destroy!
  rescue
    flash.now[:alert] = "通知をオフにできませんでした"
    render :destroy, status: :unprocessable_entity
  end
end
