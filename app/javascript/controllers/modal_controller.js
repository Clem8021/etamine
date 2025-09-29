// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.body.classList.add("modal-open")
  }

  close(event) {
    event.preventDefault()
    document.body.classList.remove("modal-open")
    window.location.href = event.currentTarget.getAttribute("href")
  }
}
