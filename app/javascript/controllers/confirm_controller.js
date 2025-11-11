import { Controller } from "@hotwired/stimulus"

// Ce contrôleur affiche une boîte de confirmation avant une action destructrice
export default class extends Controller {
  static values = { message: String }

  ask(event) {
    const message = this.messageValue || "Êtes-vous sûr de vouloir supprimer cet élément ?"
    if (!confirm(message)) {
      event.preventDefault()
      event.stopImmediatePropagation()
    }
  }
}
