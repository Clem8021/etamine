import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["extra", "button"]

  toggle() {
    const isHidden = this.extraTargets[0]?.classList.contains("hidden-photo")

    this.extraTargets.forEach((el) => {
      el.classList.toggle("hidden-photo", !isHidden)
    })

    this.buttonTarget.textContent = isHidden
      ? "Voir moins"
      : this.buttonTarget.dataset.showLabel
  }
}