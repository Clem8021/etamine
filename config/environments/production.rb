require "active_support/core_ext/integer/time"

Rails.application.configure do
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

  # ✅ Action Mailer (pour contact, mot de passe, etc.)
  # === Action Mailer pour HEROKU ===
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: ENV["SMTP_ADDRESS"],
  port: ENV["SMTP_PORT"],
  domain: ENV["SMTP_DOMAIN"],
  user_name: ENV["SMTP_USERNAME"],
  password: ENV["SMTP_PASSWORD"],
  authentication: :plain,
  enable_starttls_auto: true
}

config.action_mailer.default_url_options = { host: "www.letamine.fr", protocol: "https" }

  config.i18n.fallbacks = true
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [:id]
end
