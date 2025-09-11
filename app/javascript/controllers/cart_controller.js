import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["counter"]

  connect() {
    console.log("🛒 CartController connecté")
    document.addEventListener("click", this.closeIfOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.closeIfOutside)
  }

  toggle(event) {
    event.preventDefault()
    const dropdown = document.getElementById("cart-dropdown")
    dropdown.classList.toggle("hidden")
  }

  closeIfOutside = (event) => {
    const cartIcon = document.querySelector(".cart-icon")
    const dropdown = document.getElementById("cart-dropdown")

    if (!cartIcon.contains(event.target) && !dropdown.contains(event.target)) {
      dropdown.classList.add("hidden")
    }
  }

  animateCounter() {
    if (this.hasCounterTarget) {
      this.counterTarget.classList.remove("animate")
      void this.counterTarget.offsetWidth // reset l’animation
      this.counterTarget.classList.add("animate")
    }
  }
}
