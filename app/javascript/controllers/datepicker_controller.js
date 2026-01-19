import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  connect() {
    const today = new Date()
    const tomorrow = new Date(today)
    tomorrow.setDate(today.getDate() + 1)

    flatpickr(this.element, {
      minDate: tomorrow,
      dateFormat: "Y-m-d",

      // 🚫 Jours non disponibles
      disable: [
        "2026-01-20",
        "2026-01-21",
        // Dimanche & Lundi
        function (date) {
          const day = date.getDay()
          if (day === 0 || day === 1) return true

          // 🎄 25 décembre
          if (date.getDate() === 25 && date.getMonth() === 11) return true

          // 🎆 1er janvier
          if (date.getDate() === 1 && date.getMonth() === 0) return true

          return false
        }
      ],

      locale: {
        firstDayOfWeek: 1,
        weekdays: {
          shorthand: ["Dim", "Lun", "Mar", "Mer", "Jeu", "Ven", "Sam"],
          longhand: [
            "Dimanche",
            "Lundi",
            "Mardi",
            "Mercredi",
            "Jeudi",
            "Vendredi",
            "Samedi"
          ]
        },
        months: {
          shorthand: ["Jan", "Fév", "Mar", "Avr", "Mai", "Juin", "Juil", "Aoû", "Sep", "Oct", "Nov", "Déc"],
          longhand: [
            "Janvier",
            "Février",
            "Mars",
            "Avril",
            "Mai",
            "Juin",
            "Juillet",
            "Août",
            "Septembre",
            "Octobre",
            "Novembre",
            "Décembre"
          ]
        }
      },

      disableMobile: true,

      onChange: (selectedDates) => {
        const selected = selectedDates[0]
        if (!selected) return

        const day = selected.getDay()

        if (day === 0) {
          alert("❌ Les dimanches ne sont pas disponibles.")
          this.element.value = ""
        } else if (day === 1) {
          alert("❌ Les lundis ne sont pas disponibles.")
          this.element.value = ""
        } else if (selected.getDate() === 25 && selected.getMonth() === 11) {
          alert("🎄 Le 25 décembre n’est pas disponible.")
          this.element.value = ""
        } else if (selected.getDate() === 1 && selected.getMonth() === 0) {
          alert("🎆 Le 1er janvier n’est pas disponible.")
          this.element.value = ""
        }
      }
    })
  }
}
