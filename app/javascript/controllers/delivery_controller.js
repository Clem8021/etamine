import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggleMode(event) {
    const mode = event.target.value
    const deliveryFields = document.getElementById("delivery-fields")
    const pickupFields = document.getElementById("pickup-fields")

    if (mode === "delivery") {
      deliveryFields.classList.remove("hidden")
      pickupFields.classList.add("hidden")
    } else if (mode === "pickup") {
      pickupFields.classList.remove("hidden")
      deliveryFields.classList.add("hidden")
    } else {
      deliveryFields.classList.add("hidden")
      pickupFields.classList.add("hidden")
    }
  }
}
