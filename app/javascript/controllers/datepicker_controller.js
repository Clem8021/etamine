import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  static targets = ["date", "mode", "timeSlot"]

  async connect() {
    console.log("datepicker connect")
    try {
      const [closedRes, availableRes] = await Promise.all([
        fetch("/closed_dates.json"),
        fetch("/available_dates.json")
      ])
      console.log("fetches ok")
      this.closedDates = await closedRes.json()
      this.availableDates = await availableRes.json()
      console.log("closedDates", this.closedDates)
      console.log("availableDates", this.availableDates)
    } catch (e) {
      console.error("fetch error", e)
      this.closedDates = []
      this.availableDates = []
    }

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

  refreshRules() {
    if (!this.fp) return
    this.fp.set("disable", this.disabledDates())

    const selected = this.fp.selectedDates?.[0]
    if (selected) this.handleSpecialRules(selected)
  }

  disabledDates() {
    return [
      "2026-01-20",
      "2026-01-21",
      "2026-06-01",
      "2026-06-02",
      "2026-06-03",

      (date) => {
        if (date.getDay() === 1) return true

        const ymd = this.formatYMD(date)
        console.log("checking", ymd, this.availableDates?.length)

        const isClosed = (this.closedDates || []).some(cd => {
          if (cd.recurring) {
            const d = new Date(cd.date)
            return date.getDate() === d.getUTCDate() && date.getMonth() === d.getUTCMonth()
          } else {
            return ymd === cd.date
          }
        })
        if (isClosed) return true

        const entry = (this.availableDates || []).find(d => d.date === ymd)
        console.log("entry", ymd, entry)
        if (entry?.time_slot === "unavailable") return true

        return false
      }
    ]
  }

  handleSpecialRules(date) {
    const ymd = this.formatYMD(date)
    const entry = (this.availableDates || []).find(d => d.date === ymd)

    if (entry?.time_slot === "morning") {
      this.forceMorningOnly()
      return
    }

    if (entry?.time_slot === "afternoon") {
      this.forceAfternoonOnly()
      return
    }

    this.resetTimeSlots()
  }

  forceMorningOnly() {
    if (!this.hasTimeSlotTarget) return
    const select = this.timeSlotTarget
    Array.from(select.options).forEach(opt => {
      opt.disabled = opt.value === "afternoon"
    })
    if (select.value === "afternoon") select.value = "morning"
  }

  forceAfternoonOnly() {
    if (!this.hasTimeSlotTarget) return
    const select = this.timeSlotTarget
    Array.from(select.options).forEach(opt => {
      opt.disabled = opt.value === "morning"
    })
    if (select.value === "morning") select.value = "afternoon"
  }

  resetTimeSlots() {
    if (!this.hasTimeSlotTarget) return
    Array.from(this.timeSlotTarget.options).forEach(opt => (opt.disabled = false))
  }

  formatYMD(date) {
    const y = date.getFullYear()
    const m = String(date.getMonth() + 1).padStart(2, "0")
    const d = String(date.getDate()).padStart(2, "0")
    return `${y}-${m}-${d}`
  }
}
