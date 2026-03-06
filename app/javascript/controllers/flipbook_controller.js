// app/javascript/controllers/flipbook_controller.js
import { Controller } from "@hotwired/stimulus"
import { PageFlip } from "page-flip"

export default class extends Controller {
  static values = { width: Number, height: Number, images: Array }

  connect() {
    console.log("=== Flipbook connect ===")
    console.log("PageFlip défini ?", PageFlip)

    const container = this.element.querySelector(".flipbook-container")
    if (!container) {
      console.error("Pas de container flipbook trouvé")
      return
    }

    // 📱 Détection mobile
    const isMobile = window.innerWidth < 768

    // tailles dynamiques
    const width = isMobile ? 340 : 520
    const height = isMobile ? 460 : 680

    console.log("Mobile ?", isMobile)
    console.log("Width :", width, "Height :", height)

    const pageFlip = new PageFlip(container, {
      width: width,
      height: height,
      showCover: false,
      usePortrait: true,
      autoSize: true,
      mobileScrollSupport: true,
      swipeDistance: 30,
      maxShadowOpacity: 0.3
    })

    pageFlip.loadFromImages(this.imagesValue || [])
  }
}
