// app/javascript/controllers/push_notification_controller.js

import { Controller } from "@hotwired/stimulus"
// Push API操作を担うサービスクラスをインポート
import { PushSubscriptionService } from "../../api/push_subscription"
// フラッシュメッセージの表示用
import { showFlashAlert, showFlashNotice } from "../../utils/flash"

// 購読情報の作成・削除ボタン用の処理と、
// 購読情報の作成を促すモーダルの表示の処理
export default class extends Controller {
  static values = {
    vapidPublicKey: String
  }

  static targets = ["subscribeBtn", "unsubscribeBtn"]

  async connect() {
    // ServiceWorkerまたはPushManagerが非対応の場合
    if (!("serviceWorker" in navigator) || !("PushManager" in window)) {
      this.showElement("push-not-supported")
      this.hideElement("push-status-loading")
      return
    }

    this.service = new PushSubscriptionService(this.vapidPublicKeyValue)

    // ブラウザ側の既存の購読情報を取得
    const subscription = await this.service.getSubscription()

    this.hideElement("push-status-loading")

    if (subscription) {
      this.showElement("push-unsubscribe-btn")
    } else {
      this.showElement("push-subscribe-btn")
    }
  }

  // 通知をオンにするボタンが押されたときの処理
  async subscribe() {

    const btn = this.subscribeBtnTarget
    const originalText = btn.textContent
    btn.disabled = true
    btn.textContent = "登録中..."

    try {

      const permission = await Notification.requestPermission()

      if (permission !== "granted") {
        this.closeModal()
        return
      }

      // ブラウザ側で購読情報を作成
      const subscription = await this.service.createSubscription()
      if (!subscription) return

      // 購読情報の作成をアプリケーションサーバーにリクエスト
      const success = await this.service.saveSubscription(subscription)

      if (success) {
        this.hideElement("push-subscribe-btn")
        this.showElement("push-unsubscribe-btn")
        this.closeModal()
      }

    } catch {
      showFlashAlert("通知のオンにできませんでした")
    } finally {
      btn.disabled = false
      btn.textContent = originalText
    }
  }

  // 通知をオフにするボタンが押されたときの処理
  async unsubscribe() {

    const btn = this.unsubscribeBtnTarget
    const originalText = btn.textContent
    btn.disabled = true
    btn.textContent = "解除中..."

    try {
      const subscription = await this.service.getSubscription()

      if (!subscription) return

      // 購読情報の削除をアプリケーションサーバーにリクエスト
      const success = await this.service.deleteSubscription(subscription)
      if (!success) return

      // ブラウザ側の購読を削除する
      await subscription.unsubscribe()

      // DB側の削除とブラウザ側の削除の両方成功したら、成功フラッシュを表示する
      showFlashNotice("通知をオフにしました")

      this.hideElement("push-unsubscribe-btn")
      this.showElement("push-subscribe-btn")

    } catch {
      showFlashAlert("通知をオフにできませんでした")
    } finally {
      btn.disabled = false
      btn.textContent = originalText
    }
  }

  // 通知許可を促すモーダルをDOMから削除する
  closeModal() {
    const modal = document.getElementById("push-notification-modal")
    if (modal) modal.remove()
  }

  // 指定IDの要素を表示する
  showElement(id) {
    const element = document.getElementById(id)
    if (element) element.classList.remove("hidden")
  }

  // 指定IDの要素を非表示にする
  hideElement(id) {
    const element = document.getElementById(id)
    if (element) element.classList.add("hidden")
  }
}