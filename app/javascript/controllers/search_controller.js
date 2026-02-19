import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  search(event) {
    clearTimeout(this.searchTimeout)
    this.searchTimeout = setTimeout(() => {
      this.formTarget.requestSubmit()
    }, 300)
  }

  disconnect() {
    clearTimeout(this.searchTimeout)
  }
}