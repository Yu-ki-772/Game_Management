// app/javascript/controllers/clipboard_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button"]

  connect() {
    // 元のボタン内容を保存
    this.originalHTML = this.buttonTarget.innerHTML
    this.originalClasses = this.buttonTarget.className
  }

  #showFeedback(svgPath, label, stateClass) {
    const button = this.buttonTarget

    button.innerHTML = `
      <svg class="w-3 h-3" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="${svgPath}" />
      </svg>
      ${label}
    `
    button.className = `inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold rounded-md border ${stateClass}`
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
        "M5 13l4 4L19 7",
        "コピー済み",
        "clipboard-success"
      )
    }).catch((error) => {
      console.error("コピー失敗:", error)
      this.#showFeedback(
        "M6 18L18 6M6 6l12 12",
        "コピー失敗",
        "clipboard-error"
      )
    })
  }
}