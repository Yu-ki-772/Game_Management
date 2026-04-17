// app/javascript/controllers/diagnosis_form_controller.js
// 診断フォームの進捗バー更新・送信ボタン有効化

import { Controller } from "@hotwired/stimulus"

// 質問の総数
const TOTAL_QUESTIONS = 8

export default class extends Controller {
  static targets = ["footerCounter", "bar", "submit"]

  connect() {
    this.updateProgress()
  }

  onSelect() {
    this.updateProgress()
  }

  // 質問回答の進捗バーのajax更新
  updateProgress() {
    const answered = this.element.querySelectorAll("input[type='radio']:checked").length
    const progressPercent = Math.round((answered / TOTAL_QUESTIONS) * 100)

    this.footerCounterTarget.textContent = `${answered} / ${TOTAL_QUESTIONS}`
    this.barTarget.style.width           = `${progressPercent}%`
    this.submitTarget.disabled           = answered < TOTAL_QUESTIONS
  }
}