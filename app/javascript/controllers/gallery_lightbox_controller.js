import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "img", "thumb"]

  connect() {
    this.currentIndex = -1
    this._esc = this.closeOnEsc.bind(this)
    window.addEventListener("keydown", this._esc)
  }

  open(event) {
    const clicked = event.currentTarget
    this.currentIndex = this.thumbTargets.indexOf(clicked)

    this.showImage(clicked)
    this.overlayTarget.classList.remove("hidden")
    document.body.classList.add("no-scroll")
  }

  showImage(el) {
    const src = el.dataset.fullSrc || el.src
    this.imgTarget.src = src
  }

  next(event) {
    event?.stopPropagation()
    if (this.thumbTargets.length === 0 || this.currentIndex === -1) return
    this.currentIndex = (this.currentIndex + 1) % this.thumbTargets.length
    this.showImage(this.thumbTargets[this.currentIndex])
  }

  prev(event) {
    event?.stopPropagation()
    if (this.thumbTargets.length === 0 || this.currentIndex === -1) return
    this.currentIndex = (this.currentIndex - 1 + this.thumbTargets.length) % this.thumbTargets.length
    this.showImage(this.thumbTargets[this.currentIndex])
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
    if (event.key === "ArrowRight") this.next()
    if (event.key === "ArrowLeft") this.prev()
  }

  disconnect() {
    window.removeEventListener("keydown", this._esc)
  }
}