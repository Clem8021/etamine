import { Turbo } from "@hotwired/turbo-rails"

document.addEventListener("turbo:before-fetch-response", (event) => {
  const response = event.detail.fetchResponse

  if (response.response.headers.get("X-Flash-Notice")) {
    const message = response.response.headers.get("X-Flash-Notice")
    document.dispatchEvent(new CustomEvent("flash:show", { detail: { type: "notice", message } }))
  }

  if (response.response.headers.get("X-Flash-Alert")) {
    const message = response.response.headers.get("X-Flash-Alert")
    document.dispatchEvent(new CustomEvent("flash:show", { detail: { type: "alert", message } }))
  }
})
