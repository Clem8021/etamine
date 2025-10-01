RailsAdmin.config do |config|
  config.asset_source = :importmap

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app
  end

  config.main_app_name = ["Etamine", "Tableau de bord"]
  config.browser_validations = true

  # ✅ Plus besoin de forcer ici,
  # Rails utilise config/application.rb (default_locale = :fr)
end
