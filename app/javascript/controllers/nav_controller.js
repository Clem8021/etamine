// app/javascript/controllers/nav_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "actions", "toggle", "dropdownMenu"]

  connect() {
    this.handleClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.handleClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside)
  }

  /* === Burger menu (mobile) === */
  toggleMenu() {
    if (this.hasMenuTarget) {
      this.menuTarget.classList.toggle("is-open")
    }
    if (this.hasActionsTarget) {
      this.actionsTarget.classList.toggle("is-open")
    }
    if (this.hasToggleTarget) {
      this.toggleTarget.classList.toggle("is-active")
    }
  }

  /* === Dropdown Mariage mobile click === */
  toggleDropdown(event) {
    event.preventDefault()
    if (this.hasDropdownMenuTarget) {
      this.dropdownMenuTarget.classList.toggle("active")
    }
  }

  /* === Close dropdown if clicked outside === */
  handleClickOutside(event) {
    const target = event.target
    // ferme le dropdown Mariage
    if (this.hasDropdownMenuTarget && !this.dropdownMenuTarget.contains(target) &&
        target.closest(".dropdown-toggle") === null) {
      this.dropdownMenuTarget.classList.remove("active")
    }

    // ferme le menu burger si clic en dehors (mobile)
    if (this.hasMenuTarget && this.menuTarget.classList.contains("is-open") &&
        !this.element.contains(target)) {
      this.menuTarget.classList.remove("is-open")
      if (this.hasActionsTarget) this.actionsTarget.classList.remove("is-open")
      if (this.hasToggleTarget) this.toggleTarget.classList.remove("is-active")
    }
  }
}
