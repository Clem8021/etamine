import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "mainImage", "submit"]

  connect() {
    if (this.hasSelectTarget && this.hasSubmitTarget) {
      this.submitTarget.disabled = true
    }
  }

  updateImage() {
    const selectedColor = this.selectTarget.value

    // 🔓 Active le bouton uniquement si une couleur est choisie
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = !selectedColor
    }

    // (optionnel) mise à jour image
    let colorMap = {}
    try {
      colorMap = JSON.parse(this.element.dataset.colorColorsValue || "{}")
    } catch (e) {
      return
    }

    const imageName = colorMap[selectedColor]
    if (imageName && this.hasMainImageTarget) {
      this.mainImageTarget.src = `/assets/${imageName}`
    }
  }
}
