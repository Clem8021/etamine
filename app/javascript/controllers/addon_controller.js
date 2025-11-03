import { Controller } from "@hotwired/stimulus"

// data-controller="addon"
export default class extends Controller {
  static targets = ["cardFields", "message", "counter"]

  connect() {
    // Au chargement, on synchronise l'état (utile si le navigateur pré-coche la case)
    const checkbox = this.element.querySelector('input[type="checkbox"]')
    if (checkbox) this.toggleCard({ target: checkbox })
    this.updateCounter()
  }

  toggleCard(event) {
    const checked = !!event.target.checked
    if (this.hasCardFieldsTarget) {
      this.cardFieldsTarget.classList.toggle("hidden", !checked)
    }
    // Optionnel: vider le message si décoché
    // if (!checked && this.hasMessageTarget) this.messageTarget.value = ""
    this.updateCounter()
  }

  updateCounter() {
    if (!this.hasMessageTarget || !this.hasCounterTarget) return
    const max = parseInt(this.messageTarget.getAttribute("maxlength")) || 100
    const count = this.messageTarget.value.length
    this.counterTarget.textContent = `${count} / ${max} caractères`
    this.counterTarget.classList.toggle("limit-reached", count >= max)
  }
}
