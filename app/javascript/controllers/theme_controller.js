import { Controller } from "@hotwired/stimulus"

// iconの定義
// system: os設定に合わせる
// light: ライト指定
// dark: ダーク指定
const ICONS = {
  system: `<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24"
                stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path stroke="none" d="M0 0h24v24H0z" fill="none"/>
            <path d="M12 12m-9 0a9 9 0 1 0 18 0a9 9 0 1 0 -18 0" />
            <path d="M12 3v18" />
            <path d="M12 14l7 -7" />
            <path d="M12 19l8.5 -8.5" />
            <path d="M12 9l4.5 -4.5" />
          </svg>`,

  light: `<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
            <path stroke="none" d="M0 0h24v24H0z" fill="none"/>
            <path d="M18.407 16.993l.01 .01a1 1 0 0 1 -1.32 1.497l-.104 -.093a1 1 0 0 1 1.414 -1.414m-11.4 0l.01 .01a1 1 0 0 1 -1.32 1.497l-.104 -.093a1 1 0 0 1 1.414 -1.414m4.993 -9.993a5 5 0 1 1 -5 5l.005 -.217a5 5 0 0 1 4.995 -4.783m-4.993 -1.407l.01 .01a1 1 0 0 1 -1.32 1.497l-.104 -.093a1 1 0 0 1 1.414 -1.414m11.4 0l.01 .01a1 1 0 0 1 -1.32 1.497l-.104 -.093a1 1 0 1 1 1.414 -1.414m-14.397 5.407a1 1 0 0 1 .117 1.993l-.127 .007a1 1 0 0 1 -.117 -1.993zm7.99 -8a1 1 0 0 1 .993 .883l.007 .127a1 1 0 0 1 -1.993 .117l-.007 -.127a1 1 0 0 1 1 -1m8.01 8a1 1 0 0 1 .117 1.993l-.127 .007a1 1 0 0 1 -.117 -1.993zm-8.01 8a1 1 0 0 1 .993 .883l.007 .127a1 1 0 0 1 -1.993 .117l-.007 -.127a1 1 0 0 1 1 -1" />
          </svg>`,

  dark: `<svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
          <path stroke="none" d="M0 0h24v24H0z" fill="none"/>
          <path d="M12 1.992a10 10 0 1 0 9.236 13.838c.341 -.82 -.476 -1.644 -1.298 -1.31a6.5 6.5 0 0 1 -6.864 -10.787l.077 -.08c.551 -.63 .113 -1.653 -.758 -1.653h-.266l-.068 -.006l-.06 -.002z" />
        </svg>`
}
  
export default class extends Controller {
  static targets = ["icon", "toggleButton"]

  connect() {
    const saved = localStorage.getItem("theme") || "system";

    this.updateIcon(saved);

    this.mediaQuery = window.matchMedia("(prefers-color-scheme: dark)");
    this.handleOSChange = () => {
      const current = localStorage.getItem("theme") || "system";
      if (current === "system") {
        this.applyTheme("system");
      }
    };
    this.mediaQuery.addEventListener("change", this.handleOSChange);
  }

  disconnect() {
    this.mediaQuery.removeEventListener("change", this.handleOSChange);
  }

  // クリックするたびに light → dark → system → light ... と循環する
  cycleTheme() {
    const current = localStorage.getItem("theme") || "system";
    const order   = ["light", "dark", "system"];
    const next    = order[(order.indexOf(current) + 1) % order.length];

    localStorage.setItem("theme", next);
    this.applyTheme(next);
    this.updateIcon(next);
  }

  // html要素の「.dark」クラスを付け外し
  applyTheme(theme) {
    const html = document.documentElement;

    if (theme === "system") {
      const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
      html.classList.toggle("dark", prefersDark);
    } else {
      html.classList.toggle("dark", theme === "dark");
    }
  }

  // 切り替えボタンのアイコンの更新
  updateIcon(theme) {
    if (this.hasIconTarget) {
      this.iconTarget.innerHTML = ICONS[theme]
    }
  }
}