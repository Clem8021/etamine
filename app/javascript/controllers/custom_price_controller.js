import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "fields"]

  connect() {
    this.toggle()
  }

  toggle() {
    const checked = this.checkboxTarget.checked
    this.fieldsTarget.style.display = checked ? "" : "none"
  }
}
