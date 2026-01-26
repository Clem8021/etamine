import { Controller } from "@hotwired/stimulus"

// data-controller="delivery"
export default class extends Controller {
  static targets = ["deliveryFields", "pickupFields", "funeralFields", "modeSelect"]

  connect() {
    this.toggleMode() // état initial à l’ouverture
  }

  modeSelectEl() {
    // 1) target si présent
    if (this.hasModeSelectTarget) return this.modeSelectTarget
    // 2) fallback si la vue ne met pas le target
    return this.element.querySelector('select[name*="[mode]"]')
  }

  toggleMode(event) {
    const mode = event?.target?.value || this.modeSelectEl()?.value || ""

    const isDelivery = mode === "delivery"
    const isPickup = mode === "pickup"

    // Afficher/masquer sections principales
    if (this.hasDeliveryFieldsTarget) this.deliveryFieldsTarget.classList.toggle("hidden", !isDelivery)
    if (this.hasPickupFieldsTarget) this.pickupFieldsTarget.classList.toggle("hidden", !isPickup)

    // Bloc deuil : uniquement si livraison (s’il existe dans la page)
    if (this.hasFuneralFieldsTarget) {
      this.funeralFieldsTarget.classList.toggle("hidden", !isDelivery)
      this.toggleFuneralRequired(isDelivery)
    }
  }

  toggleFuneralRequired(required) {
    if (!this.hasFuneralFieldsTarget) return
    this.funeralFieldsTarget.querySelectorAll("input, select, textarea").forEach((el) => {
      if (required) el.setAttribute("required", "required")
      else el.removeAttribute("required")
    })
  }
}
