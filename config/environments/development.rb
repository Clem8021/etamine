# config/environments/development.rb
require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Code rechargé à chaud
  config.enable_reloading = true

  # Pas d’eager load en dev
  config.eager_load = false

  # Affiche les erreurs complètes
  config.consider_all_requests_local = true

  # Server-Timing
  config.server_timing = true

  # Caching (désactivé par défaut)
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.public_file_server.headers = {
      "cache-control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
  end

  config.cache_store = :memory_store

  # Active Storage
  config.active_storage.service = :local

  # Mailer — DEV : ouvre les mails dans le navigateur
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  # Logs & debug
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.active_record.query_log_tags_enabled = true
  config.active_job.verbose_enqueue_logs = true
  config.action_view.annotate_rendered_view_with_filenames = true

  # Sécurité callbacks
  config.action_controller.raise_on_missing_callback_actions = true

  # (ne pas mettre d’Action Cable open ici sauf besoin)
  # config.action_cable.disable_request_forgery_protection = true
end
