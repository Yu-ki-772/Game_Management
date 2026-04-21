// app/javascript/controllers/push_notification_controller.js
import { Controller } from "@hotwired/stimulus"
import { PushSubscriptionService } from "../api/push_subscription"

// 購読情報の作成・削除ボタン用の処理と、
// 購読情報の作成を促すモーダルの表示の処理
export default class extends Controller {
  static values = {
    vapidPublicKey: String
  }

  static targets = ["subscribeBtn", "unsubscribeBtn"]

  async connect() {
    if (!("serviceWorker" in navigator) || !("PushManager" in window)) {
      this.showElement("push-not-supported")
      this.hideElement("push-status-loading")
      return
    }

    this.service = new PushSubscriptionService(this.vapidPublicKeyValue)
    const subscription = await this.service.getSubscription()

    this.hideElement("push-status-loading")

    if (subscription) {
      this.showElement("push-unsubscribe-btn")
    } else {
      this.showElement("push-subscribe-btn")
    }
  }

  async subscribe() {
    if (!this.hasSubscribeBtnTarget) return

    const btn = this.subscribeBtnTarget
    const originalText = btn.textContent
    btn.disabled = true
    btn.textContent = "登録中..."

    try {
      if (!("serviceWorker" in navigator) || !("PushManager" in window)) {
        alert("このブラウザはプッシュ通知に対応していません")
        this.closeModal()
        return
      }

      const permission = await Notification.requestPermission()
      if (permission !== "granted") {
        this.closeModal()
        return
      }

      const subscription = await this.service.createSubscription()
      const success = await this.service.saveSubscription(subscription)

      if (success) {
        this.hideElement("push-subscribe-btn")
        this.showElement("push-unsubscribe-btn")
        this.closeModal()
      }

    } catch (error) {
    } finally {
      btn.disabled = false
      btn.textContent = originalText
    }
  }

  async unsubscribe() {
    const btn = this.hasUnsubscribeBtnTarget ? this.unsubscribeBtnTarget : null
    const originalText = btn?.textContent
    if (btn) {
      btn.disabled = true
      btn.textContent = "解除中..."
    }

    try {
      const subscription = await this.service.getSubscription()

      if (!subscription) {
        return
      }

      const success = await this.service.deleteSubscription(subscription)
      if (!success) {
        return
      }

      await subscription.unsubscribe()

      this.hideElement("push-unsubscribe-btn")
      this.showElement("push-subscribe-btn")

    } catch (error) {

    } finally {
      if (btn) {
        btn.disabled = false
        btn.textContent = originalText
      }
    }
  }

  closeModal() {
    const modal = document.getElementById("push-notification-modal")
    if (modal) modal.remove()
  }

  showElement(id) {
    const element = document.getElementById(id)
    if (element) element.classList.remove("hidden")
  }

  hideElement(id) {
    const element = document.getElementById(id)
    if (element) element.classList.add("hidden")
  }
}