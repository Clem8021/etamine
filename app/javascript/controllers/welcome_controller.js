import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="welcome"
export default class extends Controller {
  static targets = ["modal"]

  connect() {
    console.log("🌸 [WelcomeController] connecté")

    if (!this.hasModalTarget) {
      console.error("❌ Aucun élément .welcome-modal trouvé dans le DOM")
      return
    }

    // Affiche la popup après le premier scroll (à chaque visite)
    window.addEventListener("scroll", this.show.bind(this), { once: true })
  }

  show() {
    console.log("🎉 Affichage du pop-up de bienvenue")
    this.modalTarget.classList.remove("hidden")
    document.body.classList.add("no-scroll")
  }

  close() {
    console.log("❌ Pop-up fermé")
    this.modalTarget.classList.add("hidden")
    document.body.classList.remove("no-scroll")
  }
}
