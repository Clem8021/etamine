// app/javascript/controllers/calendar_controller.js
import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  static targets = ["calendar"]
  static values = { dates: Array }

  connect() {
    this.fp = flatpickr(this.calendarTarget, {
      inline: true,
      dateFormat: "Y-m-d",
      defaultDate: this.datesValue,
      onDayCreate: (dObj, dStr, fp, dayElem) => {
        const date = this.format(dayElem.dateObj)

        if (this.datesValue.includes(date)) {
          dayElem.classList.add("available-day")
        }
      },
      onChange: (selectedDates) => {
        const date = this.format(selectedDates[0])
        this.toggleDate(date)
      }
    })
  }

  async toggleDate(date) {
    const exists = this.datesValue.includes(date)

    if (exists) {
      await fetch(`/backoffice/available_dates/${date}`, {
        method: "DELETE",
        headers: { "X-CSRF-Token": this.csrfToken() }
      })

      this.datesValue = this.datesValue.filter(d => d !== date)
    } else {
      await fetch(`/backoffice/available_dates`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken()
        },
        body: JSON.stringify({ available_date: { date: date } })
      })

      this.datesValue.push(date)
    }

    this.fp.redraw()
  }

  format(date) {
    return date.toISOString().split("T")[0]
  }

  csrfToken() {
    return document.querySelector('meta[name="csrf-token"]').content
  }
}
