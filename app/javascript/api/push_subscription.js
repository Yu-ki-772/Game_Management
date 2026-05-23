// app/javascript/api/push_subscription.js

// 元の push_notification_controller.js から
// Push API の操作と公開鍵の文字列変換を抜き出したクラス。
export class PushSubscriptionService {
  // VAPID公開鍵を受け取りインスタンスプロパティに代入
  constructor(vapidPublicKey) {
    this.vapidPublicKey = vapidPublicKey
  }

  // ブラウザ側の既存のPush購読情報を取得する
  async getSubscription() {
    const registration = await navigator.serviceWorker.ready// ServiceWorkerの準備完了を待つ
    return registration.pushManager.getSubscription() // 現在の購読情報を返す
  }

  // ブラウザ側でPush購読を作成する
  async createSubscription() {
    const registration = await navigator.serviceWorker.ready // ServiceWorkerの準備完了を待つ
    // Push購読を作成して返す
    return registration.pushManager.subscribe({
      userVisibleOnly: true,
      // VAPID公開鍵をUint8Arrayに変換して渡す
      applicationServerKey: Uint8Array.fromBase64(this.vapidPublicKey, { alphabet: "base64url" })
    })
  }

  // 購読情報の作成をアプリケーションサーバーにリクエスト
  async saveSubscription(subscription) {
    // 購読情報からendpointと暗号化キーを取り出す
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

    // レスポンスボディをTurboに委譲し、フラッシュメッセージをturbo_streamに表示させる
    const html = await response.text()
    Turbo.renderStreamMessage(html)

    return response.ok
  }

  // 購読情報の削除をアプリケーションサーバーにリクエスト
  async deleteSubscription(subscription) {
    const response = await fetch("/web_push_subscriptions", {
      method: "DELETE",
      headers: csrfHeaders(),
      body: JSON.stringify({ endpoint: subscription.endpoint })
    })

    // レスポンスボディをTurboに委譲し、フラッシュメッセージをturbo_streamに表示させる
    const html = await response.text()
    Turbo.renderStreamMessage(html)

    return response.ok
  }
}

// CSRFトークンを含むリクエスト用ヘッダーを返す
function csrfHeaders() {
  return {
    "Content-Type": "application/json",
    "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
  }
}

