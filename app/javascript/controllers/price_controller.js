// app/javascript/controllers/price_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["basePrice", "budgetSelect", "quantity", "totalPrice"]

  connect() {
    // 🛡️ Sécurité ABSOLUE
    if (!this.hasBasePriceTarget) {
      console.warn("⚠️ price_controller: basePrice manquant")
      return
    }

    this.update()

    if (
      this.hasTotalPriceTarget &&
      this.totalPriceTarget.textContent.trim() === ""
    ) {
      this.totalPriceTarget.textContent = this.format(
        parseInt(this.basePriceTarget.dataset.base || 0, 10)
      )
    }
  }

  update() {
    if (!this.hasBasePriceTarget) return

    let base = parseInt(this.basePriceTarget.dataset.base || 0, 10)

    // 🎯 Sélecteur budget / roses
    if (this.hasBudgetSelectTarget) {
      const option = this.budgetSelectTarget.selectedOptions[0]
      if (option) {
        base = parseInt(option.dataset.price || base, 10)
      }
    }

    // 🌿 Addons
    this.element.querySelectorAll("[data-price-value]").forEach((addon) => {
      if (addon.checked) {
        base += parseInt(addon.dataset.priceValue || 0, 10)
      }
    })

    // 🔢 Quantité
    const quantity = this.hasQuantityTarget
      ? parseInt(this.quantityTarget.value || 1, 10)
      : 1

    const total = base * quantity

    if (this.hasTotalPriceTarget) {
      this.totalPriceTarget.textContent = this.format(total)
    }
  }

  format(cents) {
    return new Intl.NumberFormat("fr-FR", {
      style: "currency",
      currency: "EUR"
    }).format(cents / 100)
  }
}
