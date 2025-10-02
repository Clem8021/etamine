import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "actions", "toggle"]

  connect() {
    this._boundOutside = this.closeIfClickedOutside.bind(this)
    document.addEventListener("click", this._boundOutside)
  }

  disconnect() {
    document.removeEventListener("click", this._boundOutside)
  }

  toggle(e) {
    e.preventDefault()
    this.menuTarget.classList.toggle("is-open")
    if (this.hasActionsTarget) this.actionsTarget.classList.toggle("is-open")
    if (this.hasToggleTarget) this.toggleTarget.classList.toggle("is-active")
  }

  closeIfClickedOutside(e) {
    if (!this.element.contains(e.target)) {
      this.menuTarget.classList.remove("is-open")
      if (this.hasActionsTarget) this.actionsTarget.classList.remove("is-open")
      if (this.hasToggleTarget) this.toggleTarget.classList.remove("is-active")
    }
  }
}
