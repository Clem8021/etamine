document.addEventListener('DOMContentLoaded', function () {
  var form = document.querySelector('#product-modal form');
  var actionButtons = document.getElementById('post-add-to-cart-actions');

  if (form && actionButtons) {
    form.addEventListener('submit', function (event) {
      // Optionnel : empêcher la soumission si test uniquement
      // event.preventDefault();

      // Attendre un peu si besoin (ex : chargement, transition, etc.)
      setTimeout(function () {
        actionButtons.classList.remove('hidden');
      }, 500);
    });
  }
});
