// app/javascript/controllers/price_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["basePrice", "budgetSelect", "quantity", "totalPrice"]

  connect() {
    this.update()
    if (this.hasTotalPriceTarget && this.totalPriceTarget.textContent.trim() === "") {
      this.totalPriceTarget.textContent = new Intl.NumberFormat("fr-FR", {
        style: "currency",
        currency: "EUR"
      }).format((parseInt(this.basePriceTarget.dataset.base || 0, 10)) / 100.0)
    }
  }

  update() {
    let base = parseInt(this.basePriceTarget.dataset.base || 0, 10)

    // ✅ Cas où un menu déroulant existe (budget / taille)
    if (this.hasBudgetSelectTarget) {
      let selectedOption = this.budgetSelectTarget.selectedOptions[0]
      if (selectedOption) {
        let priceFromDataset = selectedOption.dataset.price
        let priceFromValue   = this.budgetSelectTarget.value
        base = parseInt(priceFromDataset || priceFromValue || base, 10)
      }
    }

    // ✅ Options additionnelles (checkbox avec data-price-value)
    let addons = this.element.querySelectorAll("[data-price-value]")
    addons.forEach((addon) => {
      if (addon.checked) {
        base += parseInt(addon.dataset.priceValue || 0, 10)
      }
    })

    // ✅ Quantité
    let quantity = this.hasQuantityTarget ? parseInt(this.quantityTarget.value || 1, 10) : 1
    let total = base * quantity

    // ✅ Affichage formaté en euros
    if (this.hasTotalPriceTarget) {
      this.totalPriceTarget.textContent = new Intl.NumberFormat("fr-FR", {
        style: "currency",
        currency: "EUR"
      }).format(total / 100.0)
    }
  }
}
