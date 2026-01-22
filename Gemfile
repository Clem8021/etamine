ruby "3.3.9"
source "https://rubygems.org"

# Core
gem "rails", "~> 8.0.2"
gem "propshaft"
gem "pg", "~> 1.4"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"

# Timezone
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Caching / Queue / Cable
#gem "solid_cache"
gem "solid_queue"

# Boot / performance
gem "bootsnap", require: false

# Optional heavy libs -> require false
gem "kamal", require: false
gem "thruster", require: false

# Stripe
gem "stripe"

# Auth
gem "devise", "~> 4.9"

# Mail + assets
gem "sassc"
gem "sprockets-rails"
gem 'rack-rewrite'

# ENV management (only dev/test)
gem "dotenv-rails", groups: [:development, :test]

gem "premailer-rails"

# ---- DEV / TEST ----
group :development do
  gem "web-console"
  gem 'letter_opener'           # ouvre mails localement
  gem "rails_admin"    # admin interface uniquement en dev
end

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "brakeman", require: false
  gem "sqlite3", "~> 1.4"
  gem "rubocop-rails-omakase", require: false
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
