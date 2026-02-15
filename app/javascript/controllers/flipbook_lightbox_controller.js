import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "inner", "flipbookRoot"]

  connect() {
    this.originalParent = this.flipbookRootTarget.parentNode
    this.originalNextSibling = this.flipbookRootTarget.nextSibling

    this._onKeydown = (e) => {
      if (e.key === "Escape") this.close()
    }
  }

  open() {
    this.overlayTarget.classList.remove("hidden")
    document.body.classList.add("no-scroll")
    window.addEventListener("keydown", this._onKeydown)

    this.innerTarget.appendChild(this.flipbookRootTarget)
    requestAnimationFrame(() => window.dispatchEvent(new Event("resize")))
  }

  close() {
    if (this.originalNextSibling) {
      this.originalParent.insertBefore(this.flipbookRootTarget, this.originalNextSibling)
    } else {
      this.originalParent.appendChild(this.flipbookRootTarget)
    }

    this.overlayTarget.classList.add("hidden")
    document.body.classList.remove("no-scroll")
    window.removeEventListener("keydown", this._onKeydown)

    requestAnimationFrame(() => window.dispatchEvent(new Event("resize")))
  }

  closeOnBackdrop(event) {
    if (event.target === this.overlayTarget) this.close()
  }

  stop(event) {
    event.stopPropagation()
  }
}
