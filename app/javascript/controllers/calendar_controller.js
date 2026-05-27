// app/javascript/controllers/calendar_controller.js
import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  static targets = ["calendar"]
  static values = { dates: Array }

  connect() {
    this._ignoreChange = false

    this.fp = flatpickr(this.calendarTarget, {
      inline: true,
      dateFormat: "Y-m-d",
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

      onDayCreate: (dObj, dStr, fp, dayElem) => {
        const date = this.format(dayElem.dateObj)
        const found = this.datesValue.find(d => d.date === date)

        if (dayElem.dateObj.getDay() === 1) {
          dayElem.classList.add("closed-day")
          return
        }

        if (found) {
          if (found.time_slot === "unavailable") {
            dayElem.classList.add("unavailable-day")
            dayElem.classList.remove("selected")  // ← force ici
          }
        }
      },

      onChange: (selectedDates) => {
        if (this._ignoreChange) {
          this._ignoreChange = false
          return
        }
        if (!selectedDates[0]) return
        const date = this.format(selectedDates[0])

        // Retire la classe selected immédiatement
        const dayElem = this.fp.calendarContainer.querySelector(`.flatpickr-day[aria-label]`)
        if (selectedDates[0]) {
          this.fp.calendarContainer.querySelectorAll(".flatpickr-day.selected").forEach(el => {
            el.classList.remove("selected")
          })
        }

        this.cycleState(date)
      }
    })
  }

  async cycleState(date) {
    const existing = this.datesValue.find(d => d.date === date)

    if (!existing) {
      await this.createDate(date, "unavailable")
    } else {
      await this.deleteDate(date)
    }

    this._ignoreChange = true
    const currentMonth = this.fp.currentMonth
    this.fp.changeMonth(currentMonth === 0 ? 1 : currentMonth - 1, false)
    this.fp.changeMonth(currentMonth, false)
  }

  async createDate(date, timeSlot) {
    await fetch("/backoffice/available_dates", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken()
      },
      body: JSON.stringify({ available_date: { date: date, time_slot: timeSlot } })
    })

    this.datesValue = [...this.datesValue, { date: date, time_slot: timeSlot }]
  }

  async updateDate(date, timeSlot) {
    await fetch(`/backoffice/available_dates/update_by_date`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken()
      },
      body: JSON.stringify({ date: date, time_slot: timeSlot })
    })

    this.datesValue = this.datesValue.map(d =>
      d.date === date ? { ...d, time_slot: timeSlot } : d
    )
  }

  async deleteDate(date) {
    await fetch(`/backoffice/available_dates/${date}`, {
      method: "DELETE",
      headers: { "X-CSRF-Token": this.csrfToken() }
    })

    this.datesValue = this.datesValue.filter(d => d.date !== date)
  }

  format(date) {
    const y = date.getFullYear()
    const m = String(date.getMonth() + 1).padStart(2, "0")
    const d = String(date.getDate()).padStart(2, "0")
    return `${y}-${m}-${d}`
  }

  csrfToken() {
    return document.querySelector('meta[name="csrf-token"]').content
  }
}
