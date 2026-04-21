// app/javascript/api/push_subscription.js
//

// 元の push_notification_controller.js から
// Push API の操作と 公開鍵の文字列変換を抜き出したクラス。
export class PushSubscriptionService {
  constructor(vapidPublicKey) {
    this.vapidPublicKey = vapidPublicKey
  }

  async getSubscription() {
    const registration = await navigator.serviceWorker.ready
    return registration.pushManager.getSubscription()
  }

  async createSubscription() {
    const registration = await navigator.serviceWorker.ready
    return registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: urlBase64ToUint8Array(this.vapidPublicKey)
    })
  }

  async saveSubscription(subscription) {
    const { endpoint, keys } = subscription.toJSON()

    const response = await fetch("/web_push_subscriptions", {
      method: "POST",
      headers: csrfHeaders(),
      body: JSON.stringify({
        endpoint,
        p256dh: keys.p256dh,
        auth:   keys.auth
      })
    })

    // レスポンスボディをTurboに委譲
    const html = await response.text()
    Turbo.renderStreamMessage(html)

    return response.ok
  }

  async deleteSubscription(subscription) {
    const response = await fetch("/web_push_subscriptions", {
      method: "DELETE",
      headers: csrfHeaders(),
      body: JSON.stringify({ endpoint: subscription.endpoint })
    })

    // レスポンスボディをTurboに委譲
    const html = await response.text()
    Turbo.renderStreamMessage(html)  

    return response.ok
  }
}

function csrfHeaders() {
  return {
    "Content-Type": "application/json",
    "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
  }
}

// Web Push の VAPID 公開鍵（URL-safe Base64）を Uint8Array に変換する。
function urlBase64ToUint8Array(base64String) {
  const padding = "=".repeat((4 - (base64String.length % 4)) % 4)
  const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/")
  const rawData = window.atob(base64)
  return Uint8Array.from([...rawData].map((char) => char.charCodeAt(0)))
}