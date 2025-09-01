import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle() {
    const dropdown = document.getElementById("cart-dropdown");
    dropdown.classList.toggle("show");
  }

  closeIfOutside(event) {
    const cartIcon = document.querySelector(".cart-icon");
    const dropdown = document.getElementById("cart-dropdown");

    if (!cartIcon.contains(event.target) && !dropdown.contains(event.target)) {
      dropdown.classList.remove("show");
    }
  }
}
