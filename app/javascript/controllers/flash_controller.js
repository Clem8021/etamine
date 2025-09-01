import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("⚡ Flash controller connecté !")
  }

  notify(message, type = "notice") {
    const flash = document.createElement("div")
    flash.classList.add("flash", `flash-${type}`)
    flash.textContent = message

    this.element.appendChild(flash)

    setTimeout(() => {
      flash.remove()
    }, 3000)
  }
}
