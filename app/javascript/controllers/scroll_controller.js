import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.querySelectorAll('a[href^="#"], a[href*="#"]').forEach(link => {
      link.addEventListener("click", (e) => {
        const targetId = link.getAttribute("href").split("#")[1]
        if (targetId) {
          e.preventDefault()
          const targetElement = document.getElementById(targetId)
          if (targetElement) {
            const navbarHeight = document.querySelector(".navbar").offsetHeight
            const elementPosition = targetElement.getBoundingClientRect().top + window.pageYOffset
            const offsetPosition = elementPosition - navbarHeight

            window.scrollTo({
              top: offsetPosition,
              behavior: "smooth"
            })
          }
        }
      })
    })
  }
}
