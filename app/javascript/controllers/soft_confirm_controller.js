import { Controller } from "@hotwired/stimulus"

// Contrôleur Stimulus pour confirmation douce avant suppression
export default class extends Controller {
  static values = {
    title: String,
    message: String,
    confirmLabel: { type: String, default: "Confirmer" },
    cancelLabel: { type: String, default: "Annuler" }
  }

  open(event) {
    event.preventDefault() // ⚠️ empêche le submit immédiat

    this.originalButton = event.currentTarget

    // Si un popup existe déjà → on l'enlève
    const existing = document.querySelector(".sc-backdrop")
    if (existing) existing.remove()

    // Création du fond et du dialogue
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
        <button class="sc-btn sc-btn-secondary sc-cancel">${this.cancelLabelValue}</button>
        <button class="sc-btn sc-btn-primary sc-confirm">${this.confirmLabelValue}</button>
      </div>
    `
    backdrop.appendChild(dialog)
    document.body.appendChild(backdrop)

    // Empêche le scroll de fond
    document.body.classList.add("sc-lock")

    // Gestion des boutons
    dialog.querySelector(".sc-cancel").addEventListener("click", () => this.close(backdrop))
    dialog.querySelector(".sc-confirm").addEventListener("click", () => this.confirm(backdrop))
  }

  close(backdrop) {
    backdrop.classList.remove("is-open")
    document.body.classList.remove("sc-lock")
    setTimeout(() => backdrop.remove(), 150)
  }

  confirm(backdrop) {
    // ✅ Ferme la modale
    this.close(backdrop)

    // ✅ Déclenche le vrai clic sur le bouton initial
    this.originalButton.removeAttribute("data-action")
    this.originalButton.click()
  }
}
