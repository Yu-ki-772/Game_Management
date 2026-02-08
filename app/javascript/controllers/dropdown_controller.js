import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  
  connect() {
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
  }
  
  // ドロップダウンの開閉
  toggle() {
    this.menuTarget.classList.toggle("hidden")
    
    if (!this.menuTarget.classList.contains("hidden")) {
      document.addEventListener("click", this.boundHandleClickOutside)
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
}