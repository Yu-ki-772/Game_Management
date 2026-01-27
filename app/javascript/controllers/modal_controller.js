import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { alarmLogId: String }

  connect() {
    const params = new URLSearchParams(window.location.search)
    if (params.get('show_modal') === this.alarmLogIdValue) {
      this.open()
    }
  }

  // モーダルを開くときの処理
  open() {
    this.element.classList.remove('opacity-0', 'pointer-events-none')
    this.element.classList.add('opacity-100', 'pointer-events-auto')
    document.body.classList.add('overflow-hidden') // モーダルの外側のスクロールを無効化
  }

  // モーダルを閉じるときの処理
  close() {
    const url = new URL(window.location)
    url.searchParams.delete('show_modal')
    window.history.replaceState({}, '', url)
    
    this.element.classList.remove('opacity-100', 'pointer-events-auto')
    this.element.classList.add('opacity-0', 'pointer-events-none')
    document.body.classList.remove('overflow-hidden')
  }

  disconnect() {
    document.body.classList.remove('overflow-hidden') // モーダルの外側のスクロールを無効化
  }
}