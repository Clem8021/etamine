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
      disableMobile: true,
      onChange: (selectedDates) => {
        const selected = selectedDates[0]
        if (!selected) return
        this.handleSpecialRules(selected)
      }
    })

    // applique les règles au chargement (si mode/date déjà remplis)
    this.refreshRules()
  }

  // Appelé quand on change le mode (delivery/pickup)
  refreshRules() {
    if (!this.fp) return

    // 1) mettre à jour les jours désactivés selon le mode
    this.fp.set("disable", this.disabledDates())

    // 2) re-check règles spéciales si une date est déjà choisie
    const selected = this.fp.selectedDates?.[0]
    if (selected) this.handleSpecialRules(selected)
  }

  disabledDates() {
    const isDelivery = this.modeTarget?.value === "delivery"
    const specialNoDeliveryDate = "2026-05-08"

    return [
      "2026-01-20",
      "2026-01-21",

      // ❌ le 8 mai 2026 uniquement si livraison
      ...(isDelivery ? [specialNoDeliveryDate] : []),

      // Dimanche & Lundi + 25/12 + 01/01
      (date) => {
        const day = date.getDay()
        if (day === 0 || day === 1) return true

        if (date.getDate() === 25 && date.getMonth() === 11) return true
        if (date.getDate() === 1 && date.getMonth() === 0) return true

        return false
      }
    ]
  }

  handleSpecialRules(selectedDate) {
    const ymd = this.fp.formatDate(selectedDate, "Y-m-d")
    const isDelivery = this.modeTarget?.value === "delivery"

    // 🔥 Règle : 8 mai 2026
    if (ymd === "2026-05-08") {
      if (isDelivery) {
        alert("❌ Le 8 mai 2026, les livraisons ne sont pas possibles. Merci de choisir une autre date ou le retrait boutique (matin).")
        this.fp.clear()
        return
      }

      // pickup : uniquement matin
      this.forceMorningOnly()
      return
    }

    // Sinon, on remet les créneaux normaux
    this.resetTimeSlots()
  }

  forceMorningOnly() {
    if (!this.hasTimeSlotTarget) return

    // adapte si tes values sont "morning"/"afternoon" (ou "matin"/"apresmidi")
    const morningValues = ["morning", "matin"]
    const afternoonValues = ["afternoon", "apresmidi", "après-midi", "après_midi"]

    const select = this.timeSlotTarget
    const options = Array.from(select.options)

    options.forEach((opt) => {
      if (afternoonValues.includes(opt.value)) opt.disabled = true
      if (morningValues.includes(opt.value)) opt.disabled = false
    })

    // si actuellement sur après-midi, on force sur matin
    if (afternoonValues.includes(select.value) || !select.value) {
      const morningOpt = options.find(o => morningValues.includes(o.value) && !o.disabled)
      if (morningOpt) select.value = morningOpt.value
    }
  }

  resetTimeSlots() {
    if (!this.hasTimeSlotTarget) return
    Array.from(this.timeSlotTarget.options).forEach((opt) => (opt.disabled = false))
  }
}
