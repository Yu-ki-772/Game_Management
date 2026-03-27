// app/javascript/controllers/disclosure_controller.js
import { Controller } from "@hotwired/stimulus"

const openStates = new Map()

export default class extends Controller {
  static targets = ["content", "icon"]
  static values = {
    open: { type: Boolean, default: false },
    key: String  // ERB から reason の文字列を受け取る
  }

  connect() {
    if (openStates.has(this.keyValue)) {
      this.openValue = openStates.get(this.keyValue)
    }
  }

  toggle() {
    this.openValue = !this.openValue
    openStates.set(this.keyValue, this.openValue)
  }

  openValueChanged() {
    this.contentTarget.classList.toggle("hidden", !this.openValue)
    this.iconTarget.classList.toggle("-rotate-90", !this.openValue)
  }
}