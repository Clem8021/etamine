require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.action_controller.default_url_options = {
    host: "www.letamine.fr",
    protocol: "https"
  }

  # --- Cookies partagés entre letamine.fr et www.letamine.fr ---
  config.session_store :cookie_store,
    key: "_etamine_session",
    domain: :all,          # permet le partage de session entre les sous-domaines
    secure: true,          # obligatoire en production HTTPS
    same_site: :lax

  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false

  # ✅ Cache et fichiers statiques
  config.action_controller.perform_caching = true
  config.public_file_server.headers = { "Cache-Control" => "public, max-age=#{1.year.to_i}" }
  config.active_storage.service = :local

  # ✅ SSL et redirection propre
  config.force_ssl = true
  config.assume_ssl = true

  # ✅ Hôtes autorisés (sinon Rails bloque le chargement)
  config.hosts << "letamine.fr"
  config.hosts << "www.letamine.fr"

  # ✅ Logs
  config.log_tags = [:request_id]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false
  config.cache_store = :solid_cache_store

  # ✅ Jobs
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }
  #config.solid_queue.connects_to = { database: { writing: :primary } }

 # === Action Mailer (production) ===
  config.action_mailer.default_url_options = { host: "www.letamine.fr", protocol: "https" }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true            # ✅ important en prod
  config.action_mailer.raise_delivery_errors = true          # ✅ pour voir les erreurs

  config.action_mailer.smtp_settings = {
    address:              "smtp.ionos.fr",
    port:                 587,
    domain:               ENV["MAILER_DOMAIN"],              # ex: "letamine.fr"
    user_name:            ENV["MAILER_USER_NAME"],           # ex: "contact@letamine.fr"
    password:             ENV["MAILER_PASSWORD"],            # mot de passe de la boîte
    authentication:       :plain,
    enable_starttls_auto: true
    # openssl_verify_mode: "none" # ❌ à éviter, n’activer qu’en dernier recours pour déboguer
  }
end
