import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "dots"]
  static values = {
    images: Array,
    interval: { type: Number, default: 4000 }
  }

  connect() {
    this.index = 0
    console.log("Slideshow connecté ✅", this.imagesValue)
    this.showImage(this.index)
    this.start()
  }
  disconnect() {
    this.stop()
  }

  start() {
    this.timer = setInterval(() => this.next(), this.intervalValue)
  }

  stop() {
    if (this.timer) clearInterval(this.timer)
  }

  next() {
    this.index = (this.index + 1) % this.imagesValue.length
    this.showImage(this.index)
  }

  goTo(event) {
    this.index = parseInt(event.currentTarget.dataset.index, 10)
    this.showImage(this.index)
    this.stop()
    this.start()
  }

  showImage(index) {
    this.imageTarget.src = this.imagesValue[index]

    // update active dot
    if (this.hasDotsTarget) {
      this.dotsTarget.querySelectorAll("span").forEach((dot, i) => {
        dot.classList.toggle("active", i === index)
      })
    }
  }
}
