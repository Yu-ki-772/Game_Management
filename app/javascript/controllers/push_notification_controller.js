// app/javascript/controllers/push_notification_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    vapidPublicKey: String
  }

  async connect() {
    if (!("serviceWorker" in navigator) || !("PushManager" in window)) {
      this.showElement("push-not-supported")
      this.hideElement("push-status-loading")
      return
    }

    const registration = await navigator.serviceWorker.ready
    const subscription = await registration.pushManager.getSubscription()

    this.hideElement("push-status-loading")

    if (subscription) {
      this.showElement("push-unsubscribe-btn")
    } else {
      this.showElement("push-subscribe-btn")
    }
  }

  async subscribe() {
    if (!("serviceWorker" in navigator) || !("PushManager" in window)) {
      alert("このブラウザはプッシュ通知に対応していません");
      this.closeModal()
      return;
    }

    const permission = await Notification.requestPermission();
    if (permission !== "granted") {
      console.log("Push通知が拒否されました");
      this.closeModal()
      return;
    }

    try {
      const registration = await navigator.serviceWorker.ready;
      const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: this.urlBase64ToUint8Array(this.vapidPublicKeyValue)
      });

      const success = await this.saveSubscription(subscription);
      if (success) {
        console.log("[Push] 購読完了");
        this.hideElement("push-subscribe-btn")
        this.showElement("push-unsubscribe-btn")
      } else {
        console.error("[Push] サーバーへの保存に失敗しました");
      }
    } catch (error) {
      console.error("[Push] 購読エラー:", error);
    } finally {
      this.closeModal()
    }
  }

  async unsubscribe() {
    const registration = await navigator.serviceWorker.ready;
    const subscription = await registration.pushManager.getSubscription();

    if (!subscription) {
      console.log("[Push] 購読情報が見つかりません");
      return;
    }

    try {
      const success = await this.deleteSubscription(subscription);
      if (!success) {
        console.error("[Push] サーバー側の削除に失敗しました");
        return;
      }

      await subscription.unsubscribe();
      console.log("[Push] 購読解除完了");

      // 通知設定ページでボタンを切り替える
      this.hideElement("push-unsubscribe-btn")
      this.showElement("push-subscribe-btn")
    } catch (error) {
      console.error("[Push] 購読解除エラー:", error);
    }
  }

  async saveSubscription(subscription) {
    const { endpoint, keys } = subscription.toJSON();

    const response = await fetch("/web_push_subscriptions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        endpoint,
        p256dh: keys.p256dh,
        auth:   keys.auth
      })
    });

    return response.ok;
  }

  async deleteSubscription(subscription) {
    const response = await fetch("/web_push_subscriptions", {
      method: "DELETE",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ endpoint: subscription.endpoint })
    });

    return response.ok;
  }

  closeModal() {
    const modal = document.getElementById("push-notification-modal")
    if (modal) modal.remove()
  }

  // 要素が存在する場合のみ hidden クラスを外す
  showElement(id) {
    const element = document.getElementById(id)
    if (element) element.classList.remove("hidden")
  }

  // 要素が存在する場合のみ hidden クラスを追加する
  hideElement(id) {
    const element = document.getElementById(id)
    if (element) element.classList.add("hidden")
  }

  urlBase64ToUint8Array(base64String) {
    // Base64 を atob() が読めるように変換
    const padding = "=".repeat((4 - (base64String.length % 4)) % 4);
    const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/");

    // Base64文字列をバイト値の配列（Uint8Array）に変換
    const rawData = window.atob(base64);
    return Uint8Array.from([...rawData].map((char) => char.charCodeAt(0)));
  }
}