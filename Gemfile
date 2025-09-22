ruby "3.3.9"
source "https://rubygems.org"

gem "rails", "~> 8.0.2"
gem "propshaft"
gem "pg", "~> 1.4"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"

gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false

# my gems
gem "rails_admin"
gem "sprockets-rails"
gem "sassc"
gem "stripe"
gem "dotenv-rails", groups: [:development, :test]
gem "devise", "~> 4.9"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "sqlite3", "~> 2.7"
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
