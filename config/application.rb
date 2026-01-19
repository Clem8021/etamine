# config/application.rb
require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Etamine
  class Application < Rails::Application
    # Load paths
    config.eager_load_paths << Rails.root.join("lib")

    # ⚠️ Middleware pour forcer site off
    config.middleware.insert_before 0, ForceOffline

    # Defaults Rails
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])

    # I18n
    config.i18n.default_locale = :fr
    config.i18n.available_locales = [:en, :fr]

    # Active Job
    # config.active_job.queue_adapter = :async
  end
end
