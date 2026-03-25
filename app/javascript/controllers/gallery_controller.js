// app/javascript/controllers/gallery_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "fullImage"]

  open(event) {
    const src = event.target.getAttribute("src")

    this.fullImageTarget.src = src
    this.modalTarget.classList.add("active")

    document.addEventListener("keydown", this.handleEsc)
  }

  close() {
    this.modalTarget.classList.remove("active")
    document.removeEventListener("keydown", this.handleEsc)
  }

  outside(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  handleEsc = (e) => {
    if (e.key === "Escape") this.close()
  }
}
