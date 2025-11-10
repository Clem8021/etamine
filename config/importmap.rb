# config/importmap.rb
pin "application"
pin "@hotwired/turbo-rails",      to: "turbo.min.js"
pin "@hotwired/stimulus",         to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Flipbook (PageFlip ESM)
pin "page-flip", to: "https://cdn.jsdelivr.net/npm/page-flip@2.0.7/dist/js/page-flip.module.js"

# PDF.js ESM + worker (versions stables)
pin "pdfjs",        to: "https://cdn.jsdelivr.net/npm/pdfjs-dist@4.7.76/build/pdf.mjs"

# Optionnel
pin "flatpickr"
