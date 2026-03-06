import { Controller } from "@hotwired/stimulus"

// Auto-scroll to bottom whenever the messages container is updated
export default class extends Controller {
  connect() {
    this.scrollToBottom()

    // Observe DOM changes (Turbo Stream append will trigger it)
    this.observer = new MutationObserver(() => {
      this.scrollToBottom()
    })

    this.observer.observe(this.element, { childList: true, subtree: true })
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  scrollToBottom() {
    this.element.scrollTop = this.element.scrollHeight
  }
}