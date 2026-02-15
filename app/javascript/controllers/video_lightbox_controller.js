import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "player", "preview"]

  connect() {
    this._onKeydown = (e) => {
      if (e.key === "Escape") this.close()
    }

    this.setupIntersectionObserver()
  }

  setupIntersectionObserver() {
    if (!this.hasPreviewTarget) return

    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            this.playPreview()
          } else {
            this.pausePreview()
          }
        })
      },
      {
        threshold: 0.6 // % visible pour déclencher
      }
    )

    this.observer.observe(this.previewTarget)
  }

  playPreview() {
    if (this.previewTarget.paused) {
      this.previewTarget.play().catch(() => {})
    }
  }

  pausePreview() {
    if (!this.previewTarget.paused) {
      this.previewTarget.pause()
    }
  }

  open() {
    this.overlayTarget.classList.remove("hidden")
    document.body.classList.add("no-scroll")
    window.addEventListener("keydown", this._onKeydown)

    // Stop la preview quand on ouvre la lightbox
    this.pausePreview()
  }

  close() {
    this.playerTarget.pause()
    this.playerTarget.currentTime = 0

    this.overlayTarget.classList.add("hidden")
    document.body.classList.remove("no-scroll")
    window.removeEventListener("keydown", this._onKeydown)
  }

  closeOnBackdrop(event) {
    if (event.target === this.overlayTarget) this.close()
  }

  stop(event) {
    event.stopPropagation()
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }
}
