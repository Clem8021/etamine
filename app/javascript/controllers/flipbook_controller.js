import { Controller } from "@hotwired/stimulus"
import * as pdfjsLib from "pdfjs-dist"

export default class extends Controller {
  static values = { url: String }
  static targets = ["canvas", "loader", "error", "page", "prev", "next"]

  async connect() {
    if (!this.urlValue) return this.showError("URL du PDF manquante")

    // Worker PDF.js
    pdfjsLib.GlobalWorkerOptions.workerSrc =
      "https://ga.jspm.io/npm:pdfjs-dist@4.10.38/build/pdf.worker.mjs"

    this.pageNumber = 1
    this.scale = 1.4
    this.pdf = null
    this.rendering = false
    this.pendingPage = null
    this.renderTask = null

    try {
      this.showLoader(true)
      this.pdf = await pdfjsLib.getDocument(this.urlValue).promise
      this.totalPages = this.pdf.numPages
      this.updateButtons()
      await this.renderPage(this.pageNumber)
    } catch (e) {
      this.showError()
      console.error(e)
    } finally {
      this.showLoader(false)
    }

    // Redimensionnement automatique
    this._onResize = () => this.queueRender(this.pageNumber)
    window.addEventListener("resize", this._onResize)
  }

  disconnect() {
    window.removeEventListener("resize", this._onResize)
    if (this.renderTask) this.renderTask.cancel()
  }

  prev() {
    if (this.pageNumber <= 1) return
    this.pageNumber -= 1
    this.queueRender(this.pageNumber)
  }

  next() {
    if (this.pageNumber >= this.totalPages) return
    this.pageNumber += 1
    this.queueRender(this.pageNumber)
  }

  queueRender(num) {
    if (this.rendering) {
      this.pendingPage = num
      return
    }
    this.renderPage(num)
  }

  async renderPage(num) {
    this.rendering = true
    this.updateButtons()

    const page = await this.pdf.getPage(num)

    // ✅ Largeur du container
    const containerWidth = this.canvasTarget.parentElement.clientWidth
    const viewportAt1 = page.getViewport({ scale: 1 })

    // Ajustement du scale pour ne pas être trop zoomé
    const fitScale = Math.min((containerWidth / viewportAt1.width) * 0.85, 1)
    const viewport = page.getViewport({ scale: fitScale })

    const canvas = this.canvasTarget
    const ctx = canvas.getContext("2d")

    canvas.width = Math.floor(viewport.width)
    canvas.height = Math.floor(viewport.height)

    await page.render({ canvasContext: ctx, viewport }).promise

    // Affichage de la page actuelle / total
    if (this.hasPageTarget) {
      this.pageTarget.textContent = `${num} / ${this.totalPages}`
    }

    this.rendering = false
    if (this.pendingPage) {
      const p = this.pendingPage
      this.pendingPage = null
      this.renderPage(p)
    }
  }

  updateButtons() {
    if (this.hasPrevTarget) this.prevTarget.disabled = this.pageNumber <= 1
    if (this.hasNextTarget) this.nextTarget.disabled = this.pageNumber >= (this.totalPages || 1)
  }

  showLoader(on) {
    if (!this.hasLoaderTarget) return
    this.loaderTarget.classList.toggle("hidden", !on)
  }

  showError(msg) {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = msg
      this.errorTarget.classList.remove("hidden")
    }
    this.showLoader(false)
  }
}
