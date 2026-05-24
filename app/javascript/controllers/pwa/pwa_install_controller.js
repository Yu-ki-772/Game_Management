import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // standalone モード = 既にPWAとしてホーム画面から起動されている
    // 場合は、モーダルを消す。
    if (window.matchMedia("(display-mode: standalone)").matches) {
      this.element.remove()
      return
    }

    // beforeinstallprompt が使えるブラウザ（Chrome・Edge等）には
    // ワンクリックで追加できるボタンを表示。
    // そうでないブラウザ（Safari等）には手順案内を表示。
    if (window.deferredInstallPrompt) {
      document.getElementById("pwa-install-btn").classList.remove("hidden")
    } else {
      document.getElementById("pwa-manual-guide").classList.remove("hidden")
    }
  }

  async install() {
    if (!window.deferredInstallPrompt) return

    window.deferredInstallPrompt.prompt()

    const { outcome } = await window.deferredInstallPrompt.userChoice

    // prompt() は一度しか呼べないため使用後にクリアする
    window.deferredInstallPrompt = null

    this.element.remove()
  }

  close() {
    this.element.remove()
  }
}