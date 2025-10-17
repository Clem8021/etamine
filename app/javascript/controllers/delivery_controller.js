import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["deliveryFields", "pickupFields"]

  toggleMode(event) {
    const mode = event.target.value

    if (mode === "delivery") {
      this.deliveryFieldsTarget.classList.remove("hidden")
      this.pickupFieldsTarget.classList.add("hidden")
    } else if (mode === "pickup") {
      this.pickupFieldsTarget.classList.remove("hidden")
      this.deliveryFieldsTarget.classList.add("hidden")
    } else {
      this.deliveryFieldsTarget.classList.add("hidden")
      this.pickupFieldsTarget.classList.add("hidden")
    }
  }
}
