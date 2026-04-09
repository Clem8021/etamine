import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "actions", "toggle"]

  connect() {
    this.clickOutside = this.clickOutside.bind(this)
    document.addEventListener("click", this.clickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.clickOutside)
  }

  toggle() {
    this.menuTarget.classList.toggle("active")
    this.actionsTarget.classList.toggle("is-open")
    this.toggleTarget.classList.toggle("is-active")
  }

  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.remove("active")
      this.actionsTarget.classList.remove("is-open")
      this.toggleTarget.classList.remove("is-active")
    }
  }
}
