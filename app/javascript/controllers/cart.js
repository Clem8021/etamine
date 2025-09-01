function toggleCartDropdown() {
  const dropdown = document.getElementById("cart-dropdown");
  dropdown.classList.toggle("show");
}

document.addEventListener("click", function(event) {
  const cartIcon = document.querySelector(".cart-icon");
  const dropdown = document.getElementById("cart-dropdown");

  if (!cartIcon.contains(event.target) && !dropdown.contains(event.target)) {
    dropdown.classList.remove("show");
  }
});
