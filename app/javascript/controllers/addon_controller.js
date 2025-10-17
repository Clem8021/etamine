import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="addon"
export default class extends Controller {
  static targets = ["cardFields"]

  toggleCard(event) {
    if (event.target.checked) {
      this.cardFieldsTarget.classList.remove("hidden")
    } else {
      this.cardFieldsTarget.classList.add("hidden")
    }
  }
}
