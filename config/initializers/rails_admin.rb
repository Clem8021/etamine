# config/initializers/rails_admin.rb

if defined?(RailsAdmin)
  RailsAdmin.config do |config|
    config.asset_source = :importmap

    ### ✅ Authentification et autorisation
    config.authenticate_with do
      unless current_user && current_user.admin?
        redirect_to main_app.root_path, alert: "Accès réservé à l’administrateur."
      end
    end
    config.current_user_method(&:current_user)

    ### Actions disponibles dans l'interface
    config.actions do
      dashboard
      index
      new
      export
      bulk_delete
      show
      edit
      delete
      show_in_app
    end

    ### ✅ Configuration du modèle Order
    config.model Order do
      show do
        field :id
        field :status
        field :card_message
        field :card_message_text
        field :order_items
        field :delivery_details
      end
    end

    ### Nom affiché dans le header
    config.main_app_name = ["Etamine", "Tableau de bord"]

    ### Validation front
    config.browser_validations = true
  end
end
