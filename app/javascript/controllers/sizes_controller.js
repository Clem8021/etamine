import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list"]

  add() {
    this.listTarget.insertAdjacentHTML("beforeend", `
      <div class="size-row" data-sizes-target="row" style="display:flex; gap:10px; align-items:center; margin-bottom:8px;">
        <input type="text" name="product[size_labels][]" class="input" placeholder="Taille (ex: Petit)">
        <input type="number" name="product[size_cents][]" class="input" placeholder="Centimes (ex: 3500)" min="0">
        <button type="button" class="btn btn-outline" data-action="sizes#remove">Supprimer</button>
      </div>
    `)
  }

  remove(event) {
    event.currentTarget.closest(".size-row").remove()
  }
}
