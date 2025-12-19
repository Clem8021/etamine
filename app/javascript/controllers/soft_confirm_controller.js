import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    title: String,
    message: String,
    confirmLabel: { type: String, default: "Confirmer" },
    cancelLabel: { type: String, default: "Annuler" }
  }

  open(event) {
    // ✅ Si déjà confirmé, on laisse le submit normal se faire
    if (event.currentTarget.dataset.scConfirmed === "1") return

    event.preventDefault()
    event.stopPropagation()

    this.originalButton = event.currentTarget
    this.originalForm = this.originalButton.closest("form")

    // Si un popup existe déjà → on l'enlève
    const existing = document.querySelector(".sc-backdrop")
    if (existing) existing.remove()

    const backdrop = document.createElement("div")
    backdrop.classList.add("sc-backdrop", "is-open")

    const dialog = document.createElement("div")
    dialog.classList.add("sc-dialog")

    dialog.innerHTML = `
      <div class="sc-header">
        <h3>${this.titleValue || "Confirmation"}</h3>
      </div>
      <div class="sc-body">
        <p>${this.messageValue || "Voulez-vous vraiment continuer ?"}</p>
      </div>
      <div class="sc-actions">
        <button type="button" class="sc-btn sc-btn-secondary sc-cancel">${this.cancelLabelValue}</button>
        <button type="button" class="sc-btn sc-btn-primary sc-confirm">${this.confirmLabelValue}</button>
      </div>
    `

    backdrop.appendChild(dialog)
    document.body.appendChild(backdrop)
    document.body.classList.add("sc-lock")

    dialog.querySelector(".sc-cancel").addEventListener("click", () => this.close(backdrop))
    dialog.querySelector(".sc-confirm").addEventListener("click", () => this.confirm(backdrop))
  }

  close(backdrop) {
    document.body.classList.remove("sc-lock")
    backdrop.remove()
  }

  confirm(backdrop) {
    this.close(backdrop)

    // ✅ Marque “confirmé” pour que le prochain submit ne repasse pas par open()
    this.originalButton.dataset.scConfirmed = "1"

    // ✅ Soumet le form directement (pas de .click() → pas de double cycle)
    if (this.originalForm?.requestSubmit) {
      this.originalForm.requestSubmit()
    } else {
      this.originalForm.submit()
    }

    // (optionnel) on remet à 0 après un court délai
    setTimeout(() => {
      if (this.originalButton) this.originalButton.dataset.scConfirmed = "0"
    }, 500)
  }
}
