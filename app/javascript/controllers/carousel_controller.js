import { Controller } from "@hotwired/stimulus"

// data-controller="carousel"
export default class extends Controller {
  static targets = ["slide"]
  static values = { interval: Number }

  connect() {
    this.index = 0
    this.showSlide(this.index)

    this.timer = setInterval(() => {
      this.next()
    }, this.intervalValue || 3000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  next() {
    this.index = (this.index + 1) % this.slideTargets.length
    this.showSlide(this.index)
  }

  showSlide(index) {
    this.slideTargets.forEach((el, i) => {
      el.classList.toggle("hidden", i !== index)
    })
  }
}
