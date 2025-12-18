// app/javascript/controllers/color_controller.js
import { Controller } from "@hotwired/stimulus"

// data-controller="color"
export default class extends Controller {
  static targets = ["select", "mainImage"]
  static values = { colors: Object }

  connect() {
    console.log("🎨 Color controller connecté")
    console.log("Couleurs :", this.colorsValue)
  }

  updateImage() {
    const selectedColor = this.selectTarget.value
    const imageName = this.colorsValue[selectedColor]

    if (imageName && this.mainImageTarget) {
      this.mainImageTarget.src = `/assets/${imageName}`
    }
  }
}
