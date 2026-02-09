import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "img"]

  open(event) {
    const clicked = event.currentTarget
    const src = clicked.dataset.fullSrc || clicked.src

    this.imgTarget.src = src
    this.overlayTarget.classList.remove("hidden")
    document.body.classList.add("no-scroll")
  }

  close() {
    this.overlayTarget.classList.add("hidden")
    this.imgTarget.src = ""
    document.body.classList.remove("no-scroll")
  }

  closeOnBackdrop(event) {
    if (event.target === this.overlayTarget) this.close()
  }

  closeOnEsc(event) {
    if (event.key === "Escape") this.close()
  }

  connect() {
    this._esc = this.closeOnEsc.bind(this)
    window.addEventListener("keydown", this._esc)
  }

  disconnect() {
    window.removeEventListener("keydown", this._esc)
  }
}
