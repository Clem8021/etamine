import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["otherField"]

  toggle(event) {
    if (event.target.value === "Autre (sur demande)") {
      this.otherFieldTarget.style.display = "block"
    } else {
      this.otherFieldTarget.style.display = "none"
    }
  }
}
