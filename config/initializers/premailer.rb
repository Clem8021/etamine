# config/initializers/premailer.rb
Premailer::Rails.config.merge!(
  preserve_styles: true,
  remove_ids: true
)
