import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // フラッシュが消えるときのduration
  static values = {
    duration: { type: Number, default: 4000 }
  }

  connect() {
    if (this.durationValue === 0) return

    this.timer = setTimeout(() => {
      this.dismiss()
    }, this.durationValue)
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  dismiss() {
    this.element.classList.add("opacity-0")

    this.element.addEventListener("transitionend", () => {
      this.element.remove()
    })
  }
}