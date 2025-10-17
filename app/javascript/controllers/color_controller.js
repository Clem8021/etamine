import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="color"
export default class extends Controller {
  static targets = ["select", "mainImage"]

  updateImage() {
    const selectedColor = this.selectTarget.value
    const colorMap = JSON.parse(this.element.dataset.colors || "{}")

    const imageName = colorMap[selectedColor]
    if (imageName && this.mainImageTarget) {
      this.mainImageTarget.src = `/assets/${imageName}`
    }
  }
}
