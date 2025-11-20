import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  connect() {
    const today = new Date()
    const tomorrow = new Date(today)
    tomorrow.setDate(today.getDate() + 1)

    flatpickr(this.element, {
      minDate: tomorrow, // ⛔ pas le jour même
      dateFormat: "Y-m-d",

      // 🚫 Désactiver dimanche (0) et lundi (1)
      disable: [
        function (date) {
          return date.getDay() === 0 || date.getDay() === 1
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

      onChange: (selectedDates, dateStr) => {
        const selected = selectedDates[0]

        if (!selected) return

        if (selected.getDay() === 0) {
          alert("❌ Les dimanches ne sont pas disponibles.")
          this.element.value = ""
        } else if (selected.getDay() === 1) {
          alert("❌ Les lundis ne sont pas disponibles.")
          this.element.value = ""
        } else if (selected.toDateString() === today.toDateString()) {
          alert("⚠️ Le jour même n’est pas disponible.")
          this.element.value = ""
        }
      }
    })
  }
}
