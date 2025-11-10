// app/javascript/controllers/flipbook_controller.js

import { Controller } from "@hotwired/stimulus"
import { PageFlip } from "page-flip"
import * as pdfjsLib from "pdfjs"

// ✅ on ne fait plus "import pdfjsWorker" du tout
// ✅ on donne simplement à PDF.js l’URL du worker
pdfjsLib.GlobalWorkerOptions.workerSrc =
  "https://cdn.jsdelivr.net/npm/pdfjs-dist@4.7.76/build/pdf.worker.mjs"

export default class extends Controller {
  static targets = ["viewer", "loader", "error"]
  static values = { url: String }

  connect() {
    this.flip = null

    // ✅ Vérifie qu'une URL est bien fournie
    if (!this.hasUrlValue) {
      this._fail(new Error("URL du PDF manquante"))
      return
    }

    this._init().catch(err => this._fail(err))
  }

  disconnect() {
    if (this.resizeObs) this.resizeObs.disconnect()
    if (this.flip) this.flip.destroy()
  }

  async _init() {
    // état initial
    this._show(this.loaderTarget)
    this._hide(this.viewerTarget)
    this._hide(this.errorTarget)

    // Dimensions initiales du viewer
    const width  = this.viewerTarget.clientWidth || 1000
    const height = this.viewerTarget.clientHeight || Math.round(window.innerHeight * 0.9)

    this.flip = new PageFlip(this.viewerTarget, {
      width,
      height,
      size: "stretch",
      minWidth: 480,
      maxWidth: 2400,
      minHeight: 400,
      maxHeight: 2400,
      showCover: false,
      mobileScrollSupport: true,
      drawShadow: true,
      flippingTime: 800,
      maxShadowOpacity: 0.3
    })

    // Charge le PDF et convertit les pages en images
    const pdf = await pdfjsLib.getDocument(this.urlValue).promise
    const pages = Array.from({ length: pdf.numPages }, (_, i) => i + 1)

    // ✅ Rendu en parallèle pour plus de rapidité
    const images = await Promise.all(
      pages.map(async (num) => {
        const page = await pdf.getPage(num)
        const viewport = page.getViewport({ scale: 2 })
        const canvas = document.createElement("canvas")
        const ctx = canvas.getContext("2d")
        canvas.width = viewport.width
        canvas.height = viewport.height
        await page.render({ canvasContext: ctx, viewport }).promise
        return canvas.toDataURL("image/png")
      })
    )

    // Injecte les pages dans PageFlip
    this.flip.loadFromImages(images)

    // Affiche le viewer une fois prêt
    this._hide(this.loaderTarget)
    this._show(this.viewerTarget)
    this.viewerTarget.classList.add("is-ready")

    // Redimensionne automatiquement si le conteneur change
    this.resizeObs = new ResizeObserver(() => {
      if (!this.flip) return
      const w = this.viewerTarget.clientWidth || 1000
      const h = this.viewerTarget.clientHeight || Math.round(window.innerHeight * 0.9)
      this.flip.update({ width: w, height: h })
    })
    this.resizeObs.observe(this.viewerTarget)
  }

  _fail(err) {
    console.error("Flipbook error:", err)
    this._hide(this.loaderTarget)
    this._hide(this.viewerTarget)
    this._show(this.errorTarget)
    this.errorTarget.textContent = err?.message || "Impossible de charger le book."
  }

  _show(el) { el.style.display = "" }
  _hide(el) { el.style.display = "none" }
}
