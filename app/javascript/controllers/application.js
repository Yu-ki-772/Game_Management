import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

window.addEventListener("beforeinstallprompt", (event) => {
  event.preventDefault()
  window.deferredInstallPrompt = event
})

export { application }
