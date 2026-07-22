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
    if (this.hasMenuTarget) this.menuTarget.classList.toggle("active")
    if (this.hasActionsTarget) this.actionsTarget.classList.toggle("is-open")
    if (this.hasToggleTarget) this.toggleTarget.classList.toggle("is-active")
  }

  clickOutside(event) {
    if (this.element.contains(event.target)) return

    if (this.hasMenuTarget) this.menuTarget.classList.remove("active")
    if (this.hasActionsTarget) this.actionsTarget.classList.remove("is-open")
    if (this.hasToggleTarget) this.toggleTarget.classList.remove("is-active")
  }
}