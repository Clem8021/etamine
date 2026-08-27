import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["extra", "button", "grid", "preview"]

  toggle() {
    const isHidden = this.extraTargets[0]?.classList.contains("hidden-photo")

    this.extraTargets.forEach((el) => {
      el.classList.toggle("hidden-photo", !isHidden)
    })

    if (this.hasGridTarget) {
      this.gridTarget.classList.toggle("is-expanded", isHidden)
    }

    if (this.hasPreviewTarget) {
      this.previewTarget.classList.toggle("has-overlay", !isHidden)
    }

    this.buttonTarget.classList.toggle("is-visible", isHidden)
    this.buttonTarget.textContent = isHidden
      ? "Voir moins"
      : this.buttonTarget.dataset.showLabel
  }
}