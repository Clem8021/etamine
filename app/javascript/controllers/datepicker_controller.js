import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  static targets = ["date", "mode", "timeSlot"]

  connect() {
    const today = new Date()
    const tomorrow = new Date(today)
    tomorrow.setDate(today.getDate() + 1)

    this.fp = flatpickr(this.dateTarget, {
      minDate: tomorrow,
      dateFormat: "Y-m-d",
      disable: this.disabledDates(),
      disableMobile: true,
      locale: {
        firstDayOfWeek: 1,
        weekdays: {
          shorthand: ["Dim", "Lun", "Mar", "Mer", "Jeu", "Ven", "Sam"],
          longhand: ["Dimanche","Lundi","Mardi","Mercredi","Jeudi","Vendredi","Samedi"]
        },
        months: {
          shorthand: ["Jan","Fév","Mar","Avr","Mai","Juin","Juil","Aoû","Sep","Oct","Nov","Déc"],
          longhand: ["Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"]
        }
      },
      onChange: (selectedDates) => {
        const selected = selectedDates[0]
        if (selected) this.handleSpecialRules(selected)
      }
    })

    this.refreshRules()
  }

  disconnect() {
    if (this.fp) this.fp.destroy()
  }

  // 🔁 appelé quand on change le mode livraison / retrait
  refreshRules() {
    if (!this.fp) return
    this.fp.set("disable", this.disabledDates())

    const selected = this.fp.selectedDates?.[0]
    if (selected) this.handleSpecialRules(selected)
  }

  // 📅 jours désactivés
  disabledDates() {
    const isDelivery = this.modeTarget?.value === "delivery"

    return [
      "2026-01-20",
      "2026-01-21",

      ...(isDelivery ? ["2026-05-08"] : []),

      (date) => {
        const ymd = this.formatYMD(date)

        // ✅ exception : dimanche 1er mars 2026 autorisé
        if (ymd === "2026-03-01") return false

        const day = date.getDay()
        if (day === 0 || day === 1) return true

        if (date.getDate() === 25 && date.getMonth() === 11) return true
        if (date.getDate() === 1 && date.getMonth() === 0) return true

        return false
      }
    ]
  }

  // ⚠️ règles spéciales selon la date choisie
  handleSpecialRules(date) {
    const ymd = this.formatYMD(date)
    const isDelivery = this.modeTarget?.value === "delivery"

    if (ymd === "2026-05-08") {
      if (isDelivery) {
        alert("❌ Le 8 mai 2026, la livraison n’est pas disponible.")
        this.fp.clear()
        return
      }

      this.forceMorningOnly()
      return
    }

    this.resetTimeSlots()
  }

  // 🕘 matin uniquement
  forceMorningOnly() {
    if (!this.hasTimeSlotTarget) return

    const morning = ["morning", "matin"]
    const afternoon = ["afternoon", "apresmidi", "après-midi", "après_midi"]

    const select = this.timeSlotTarget
    const options = Array.from(select.options)

    options.forEach(opt => {
      opt.disabled = afternoon.includes(opt.value)
    })

    if (afternoon.includes(select.value) || !select.value) {
      const morningOpt = options.find(o => morning.includes(o.value))
      if (morningOpt) select.value = morningOpt.value
    }
  }

  resetTimeSlots() {
    if (!this.hasTimeSlotTarget) return
    Array.from(this.timeSlotTarget.options).forEach(opt => (opt.disabled = false))
  }

  // 🛠 helper date → YYYY-MM-DD
  formatYMD(date) {
    const y = date.getFullYear()
    const m = String(date.getMonth() + 1).padStart(2, "0")
    const d = String(date.getDate()).padStart(2, "0")
    return `${y}-${m}-${d}`
  }
}
