document.addEventListener("scroll", function () {
  const hero = document.querySelector(".hero");
  const offset = window.scrollY * 0.5;
  hero.style.backgroundPosition = `center ${offset}px`;
});
