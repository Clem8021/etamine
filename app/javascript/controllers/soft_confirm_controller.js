import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    title: String,
    message: String,
    confirmLabel: String,
    cancelLabel: String
  }

  open(event) {
    event.preventDefault()

    this.link = event.currentTarget

    // Nettoyage si déjà ouvert
    document.querySelector(".sc-backdrop")?.remove()

    const backdrop = document.createElement("div")
    backdrop.classList.add("sc-backdrop")

    backdrop.innerHTML = `
      <div class="sc-dialog">
        <h3>${this.titleValue}</h3>
        <p>${this.messageValue}</p>
        <div class="sc-actions">
          <button class="sc-btn-cancel">Annuler</button>
          <button class="sc-btn-confirm">${this.confirmLabelValue}</button>
        </div>
      </div>
    `

    document.body.appendChild(backdrop)

    backdrop.querySelector(".sc-btn-cancel")
      .addEventListener("click", () => backdrop.remove())

    backdrop.querySelector(".sc-btn-confirm")
      .addEventListener("click", () => {
        backdrop.remove()
        this.link.click() // 🔥 Turbo fait le DELETE
      })
  }
}
