// app/javascript/api/push_subscription.js
//
// 元の push_notification_controller.js から
// Push API の操作と HTTP 通信のみを抜き出したクラス。
// フロー制御・エラーハンドリング・UI操作はコントローラー側に残してある。

export class PushSubscriptionService {
  constructor(vapidPublicKey) {
    this.vapidPublicKey = vapidPublicKey
  }

  // 元: connect() / unsubscribe() 内の
  //   const registration = await navigator.serviceWorker.ready
  //   const subscription = await registration.pushManager.getSubscription()
  async getSubscription() {
    const registration = await navigator.serviceWorker.ready
    return registration.pushManager.getSubscription()
  }

  // 元: subscribe() 内の
  //   const registration = await navigator.serviceWorker.ready
  //   const subscription = await registration.pushManager.subscribe({ ... })
  async createSubscription() {
    const registration = await navigator.serviceWorker.ready
    return registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: urlBase64ToUint8Array(this.vapidPublicKey)
    })
  }

  // 元: saveSubscription(subscription) をそのまま移動
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

    return response.ok
  }

  // 元: deleteSubscription(subscription) をそのまま移動
  async deleteSubscription(subscription) {
    const response = await fetch("/web_push_subscriptions", {
      method: "DELETE",
      headers: csrfHeaders(),
      body: JSON.stringify({ endpoint: subscription.endpoint })
    })

    return response.ok
  }
}

// --- ファイルプライベートな関数 ---

// saveSubscription / deleteSubscription 両方で使うヘッダーを共通化。
// 元のコードでは各メソッドに直書きされていたが、重複のため関数に切り出した。
function csrfHeaders() {
  return {
    "Content-Type": "application/json",
    "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
  }
}

// Web Push の VAPID 公開鍵（URL-safe Base64）を Uint8Array に変換する。
// Push 購読以外では使わないため export しない。
function urlBase64ToUint8Array(base64String) {
  const padding = "=".repeat((4 - (base64String.length % 4)) % 4)
  const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/")
  const rawData = window.atob(base64)
  return Uint8Array.from([...rawData].map((char) => char.charCodeAt(0)))
}