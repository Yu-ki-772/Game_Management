import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button"]

  connect() {
    // 元のボタン内容を保存
    this.originalHTML = this.buttonTarget.innerHTML
    this.originalClasses = this.buttonTarget.className
  }

  copy(event) {
    const text = this.sourceTarget.textContent.trim()
    const button = this.buttonTarget

    navigator.clipboard.writeText(text).then(() => {
      // 成功時：緑色 + チェックマーク
      button.innerHTML = `
        <svg class="w-3 h-3" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
        </svg>
        コピー済み
      `
      button.className = "inline-flex items-center gap-1.5 px-3 py-1.5 bg-green-50 text-green-700 text-xs font-semibold rounded-md border border-green-200"
      button.disabled = true
      
      setTimeout(() => {
        button.innerHTML = this.originalHTML
        button.className = this.originalClasses
        button.disabled = false
      }, 2000)
    }).catch((error) => {
      console.error("コピー失敗:", error)
      
      // エラー時：赤色 + ×マーク
      button.innerHTML = `
        <svg class="w-3 h-3" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
        </svg>
        コピー失敗
      `
      button.className = "inline-flex items-center gap-1.5 px-3 py-1.5 bg-red-50 text-red-700 text-xs font-semibold rounded-md border border-red-200"
      button.disabled = true
      
      setTimeout(() => {
        button.innerHTML = this.originalHTML
        button.className = this.originalClasses
        button.disabled = false
      }, 2000)
    })
  }
}