// controllers/scroll_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    window.addEventListener("scroll", this.handleScroll)
  }

  disconnect() {
    window.removeEventListener("scroll", this.handleScroll)
  }

  handleScroll = () => {
    const offset = window.scrollY * 0.5
    this.element.style.backgroundPosition = `center ${offset}px`
  }
}
