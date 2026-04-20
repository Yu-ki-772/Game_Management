// app/javascript/controllers/clipboard_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button"]

  connect() {
    this.originalHTML = this.buttonTarget.innerHTML
    this.originalClasses = this.buttonTarget.className
  }

  // label パラメータを削除。アイコンのみで状態を表現する。
  #showFeedback(svgPath, stateClass) {
    const button = this.buttonTarget

    button.innerHTML = `
      <svg class="w-4 h-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="${svgPath}" />
      </svg>
    `
    button.className = `shrink-0 p-1 rounded-md transition-colors duration-100 ${stateClass}`
    button.disabled = true

    setTimeout(() => {
      button.innerHTML = this.originalHTML
      button.className = this.originalClasses
      button.disabled = false
    }, 2000)
  }

  copy(event) {
    const text = this.sourceTarget.textContent.trim()

    navigator.clipboard.writeText(text).then(() => {
      this.#showFeedback(
        "M5 13l4 4L19 7",     // チェックマーク
        "clipboard-success"
      )
    }).catch((error) => {
      this.#showFeedback(
        "M6 18L18 6M6 6l12 12",  // ×マーク
        "clipboard-error"
      )
    })
  }
}