// app/javascript/controllers/delivery_controller.js
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="delivery"
export default class extends Controller {
  static targets = ["deliveryFields", "pickupFields"]

  connect() {
    console.log("✅ DeliveryController connecté")
    this.toggleMode()
  }

  toggleMode(event) {
    const mode = event ? event.target.value : this.element.querySelector("select[name*='mode']")?.value

    if (mode === "delivery") {
      this.showDeliveryFields()
    } else if (mode === "pickup") {
      this.showPickupFields()
    } else {
      this.hideAll()
    }
  }

  showDeliveryFields() {
    if (this.hasDeliveryFieldsTarget) this.deliveryFieldsTarget.classList.remove("hidden")
    if (this.hasPickupFieldsTarget) this.pickupFieldsTarget.classList.add("hidden")
  }

  showPickupFields() {
    if (this.hasPickupFieldsTarget) this.pickupFieldsTarget.classList.remove("hidden")
    if (this.hasDeliveryFieldsTarget) this.deliveryFieldsTarget.classList.add("hidden")
  }

  hideAll() {
    if (this.hasDeliveryFieldsTarget) this.deliveryFieldsTarget.classList.add("hidden")
    if (this.hasPickupFieldsTarget) this.pickupFieldsTarget.classList.add("hidden")
  }
}
