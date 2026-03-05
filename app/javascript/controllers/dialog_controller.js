// app/javascript/controllers/dialog_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.showModal()
  }

  close() {
    this.element.close()
  }

  // ダイアログの外側をクリックした場合に閉じる
  clickOutside(event) {
    if (event.target === this.element) this.element.close()
  }
}