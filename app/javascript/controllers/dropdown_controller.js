import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "form"] // formターゲットを追加する

  connect() {
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
  }

  toggle() {
    this.menuTarget.classList.toggle("hidden")

    if (!this.menuTarget.classList.contains("hidden")) {
      document.addEventListener("click", this.boundHandleClickOutside)

      if (this.hasFormTarget) {
        this.formTarget.requestSubmit()
      }
    } else {
      document.removeEventListener("click", this.boundHandleClickOutside)
    }
  }

  // ドロップダウンを閉じる処理
  close() {
    this.menuTarget.classList.add("hidden")
    document.removeEventListener("click", this.boundHandleClickOutside)
  }

  // ドロップダウンの外側をクリックした場合の処理
  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  disconnect() {
    this.close()
    document.removeEventListener("click", this.boundHandleClickOutside)
  }

  search(event) {
    clearTimeout(this.searchTimeout)
    this.searchTimeout = setTimeout(() => {
      event.target.closest("form").requestSubmit()
    }, 300)
  }
}