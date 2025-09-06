import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reveal"
export default class extends Controller {
  static targets = ["item"]

  connect() {
    console.log("✅ RevealController connecté !")

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const index = this.itemTargets.indexOf(entry.target)

          // ⏳ Apparition en cascade avec setTimeout
          setTimeout(() => {
            entry.target.classList.add("visible")
          }, index * 600) // 500ms de décalage entre chaque élément

          observer.unobserve(entry.target)
        }
      })
    }, { threshold: 0.3 })

    this.itemTargets.forEach(el => {
      observer.observe(el)
    })
  }
}
