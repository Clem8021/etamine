import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  connect() {
    const today = new Date()
    const tomorrow = new Date(today)
    tomorrow.setDate(today.getDate() + 1)

    flatpickr(this.element, {
      minDate: tomorrow, // ⛔ pas de jour même
      dateFormat: "Y-m-d",
      disable: [
        function (date) {
          // 1 = lundi
          return date.getDay() === 1
        }
      ],
      locale: {
        firstDayOfWeek: 1, // lundi = début de semaine
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
      disableMobile: true, // ✅ force le vrai calendrier même sur mobile
      onChange: (selectedDates, dateStr) => {
        // au cas où l’utilisateur contourne les règles
        const selected = selectedDates[0]
        if (selected.getDay() === 1) {
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
