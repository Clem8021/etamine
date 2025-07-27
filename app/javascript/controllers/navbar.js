document.addEventListener("turbo:load", () => {
  const menu = document.querySelector('#mobile-menu');
  const navLinks = document.querySelector('.navbar-links');

  if (menu && navLinks) {
    menu.addEventListener('click', () => {
      navLinks.classList.toggle('active');
    });
  }
});

document.addEventListener("turbo:load", () => {
  const navbar = document.querySelector('.navbar');
  if (navbar) {
    window.addEventListener('scroll', () => {
      if (window.scrollY > 50) {
        navbar.classList.add('scrolled');
      } else {
        navbar.classList.remove('scrolled');
      }
    });
  }
});
