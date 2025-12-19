import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit"]

  connect() {
    this.checkValidity()
  }

  checkValidity() {
    const form = this.element
    const isValid = form.checkValidity()
    this.submitTarget.disabled = !isValid
  }
}
