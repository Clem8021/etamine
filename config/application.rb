# config/application.rb
require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Etamine
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])

    config.i18n.default_locale = :fr
    config.i18n.available_locales = [:en, :fr]

    config.active_job.queue_adapter = :async

    config.load_defaults 8.0
  end
end
