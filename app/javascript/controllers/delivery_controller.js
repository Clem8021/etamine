import { Controller } from "@hotwired/stimulus"

// data-controller="delivery"
export default class extends Controller {
  static targets = ["deliveryFields", "pickupFields", "funeralFields", "modeSelect"]

  connect() {
    // Si le select n'est pas explicitement targeté, on le récupère quand même
    if (!this.hasModeSelectTarget) {
      const sel = this.element.querySelector('select[name*="[mode]"]')
      if (sel) this.modeSelectTarget = sel
    }
    this.toggleMode() // état initial à l’ouverture
  }

  toggleMode(event) {
    const mode = event?.target?.value || (this.hasModeSelectTarget ? this.modeSelectTarget.value : "")

    const isDelivery = mode === "delivery"
    const isPickup   = mode === "pickup"

    // Afficher/masquer sections principales
    if (this.hasDeliveryFieldsTarget) this.deliveryFieldsTarget.classList.toggle("hidden", !isDelivery)
    if (this.hasPickupFieldsTarget)   this.pickupFieldsTarget.classList.toggle("hidden", !isPickup)

    // Bloc deuil : uniquement si livraison (s’il existe dans la page)
    if (this.hasFuneralFieldsTarget) {
      this.funeralFieldsTarget.classList.toggle("hidden", !isDelivery)
      // (optionnel) Rendez ces champs requis uniquement si livraison
      this.toggleFuneralRequired(isDelivery)
    }
  }

  toggleFuneralRequired(required) {
    if (!this.hasFuneralFieldsTarget) return
    const inputs = this.funeralFieldsTarget.querySelectorAll("input, select, textarea")
    inputs.forEach((el) => {
      if (required) {
        el.setAttribute("required", "required")
      } else {
        el.removeAttribute("required")
      }
    })
  }
}
