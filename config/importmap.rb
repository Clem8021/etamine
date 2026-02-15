# config/importmap.rb
pin "application"
pin "@hotwired/turbo-rails",      to: "turbo.min.js"
pin "@hotwired/stimulus",         to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Flipbook (PageFlip ESM)
pin "page-flip", to: "https://cdn.jsdelivr.net/npm/page-flip@2.0.7/dist/js/page-flip.module.js"

# PDF.js ESM + worker (versions stables)
pin "pdfjs-dist", to: "https://ga.jspm.io/npm:pdfjs-dist@4.10.38/build/pdf.mjs"
pin "pdfjs-dist/build/pdf.worker.mjs", to: "https://ga.jspm.io/npm:pdfjs-dist@4.10.38/build/pdf.worker.mjs"

# Optionnel
pin "flatpickr"
