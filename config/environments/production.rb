require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.action_controller.default_url_options = {
    host: "www.letamine.fr",
    protocol: "https"
  }

  # --- Sessions ---
  config.session_store :cookie_store,
    key: "_etamine_session",
    domain: :all,
    secure: true,
    same_site: :lax

  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false

  # --- Cache / assets ---
  config.action_controller.perform_caching = true
  config.public_file_server.headers = { "Cache-Control" => "public, max-age=#{1.year.to_i}" }
  config.active_storage.service = :local

  # --- SSL ---
  config.force_ssl = true
  config.assume_ssl = true

  # --- Hosts ---
  config.hosts << "letamine.fr"
  config.hosts << "www.letamine.fr"

  # --- Logs ---
  config.log_tags = [:request_id]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false

  # --- Solid Stack ---
  # --- Cache ---
  config.cache_store = :memory_store   # simple, stable sur Heroku

  # --- Jobs ---
  config.active_job.queue_adapter = :solid_queue
  #surtout PAS de connects_to en version simple
  #config.solid_queue.connects_to = { database: { writing: :queue } }

  # --- Migrations ---
  config.active_record.dump_schema_after_migration = false

  # --- Mailer ---
  config.action_mailer.default_url_options = { host: "www.letamine.fr", protocol: "https" }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false

  config.action_mailer.smtp_settings = {
    address: "smtp.ionos.fr",
    port: 587,
    domain: ENV["MAILER_DOMAIN"].to_s.strip,
    user_name: ENV["MAILER_USER_NAME"].to_s.strip,
    password: ENV["MAILER_PASSWORD"].to_s.strip,
    authentication: :plain,
    enable_starttls_auto: true
  }
end
