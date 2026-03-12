import { Controller } from "@hotwired/stimulus"
import { PageFlip } from "page-flip"

export default class extends Controller {

  static targets = ["modal"]
  static values = { width: Number, height: Number, images: Array }

  connect() {
    this.pageFlip = null
  }

  open() {
    this.modalTarget.classList.add("active")

    if (!this.pageFlip) {
      const container = this.modalTarget.querySelector(".flipbook-container")

      this.pageFlip = new PageFlip(container, {
        width: this.widthValue,
        height: this.heightValue,
        size: "stretch",
        autoSize: true,
        usePortrait: true,
        showCover: false,
        mobileScrollSupport: true,
        maxShadowOpacity: 0.3
      })

      this.pageFlip.loadFromImages(this.imagesValue)
    }

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

  prev() {
    this.pageFlip.flipPrev()
  }

  next() {
    this.pageFlip.flipNext()
  }

  handleEsc = (event) => {
    if (event.key === "Escape") {
      this.close()
    }
  }

}
