import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "counter"]
  static values = { max: { type: Number, default: 3 } }

  connect() {
    this.update()
  }

  update() {
    const checkedCount = this.checkboxTargets.filter((cb) => cb.checked).length
    const atMax = checkedCount >= this.maxValue

    this.checkboxTargets.forEach((cb) => {
      if (!cb.checked) cb.disabled = atMax
    })

    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `(${checkedCount}/${this.maxValue} sélectionnées)`
    }
  }
}