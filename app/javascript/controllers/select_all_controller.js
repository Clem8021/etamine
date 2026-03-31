import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "selectAll"]

  connect() {
    this.updateSelectAll() // vérifie l'état au chargement
  }

  toggleAll() {
    this.checkboxTargets.forEach(cb => cb.checked = this.selectAllTarget.checked)
  }

  updateSelectAll() {
    const allChecked = this.checkboxTargets.every(cb => cb.checked)
    this.selectAllTarget.checked = allChecked
  }
}
