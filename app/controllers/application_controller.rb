class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :clean_old_orders
  before_action :redirect_to_home_if_locked # 🔒 Ajout ici
  helper_method :current_order
  layout :layout_by_resource

  private

  # ==============================================================
  # 🩷 MODE VITRINE (accès uniquement à la page d’accueil)
  # ==============================================================

  def redirect_to_home_if_locked
    return unless site_locked?

    allowed_routes = [
      { controller: "pages", action: "home" },  # ta page d’accueil
      { controller: "rails", action: "active_storage" } # assets
    ]

    unless allowed_routes.any? { |r| r[:controller] == controller_name && r[:action] == action_name }
      redirect_to root_path, notice: "🌸 Notre boutique est en préparation, revenez très bientôt !"
    end
  end

  def site_locked?
    true # 🔒 Mets à `false` quand la boutique sera prête à ouvrir
  end

  # ==============================================================
  # 🛒 Gestion du panier et commandes
  # ==============================================================

  def current_order
    if user_signed_in?
      # 🔹 On essaie d’abord de récupérer la commande stockée en session
      if session[:order_id]
        order = current_user.orders.find_by(id: session[:order_id], status: "en_attente")
      end

      # 🔹 Sinon, on en cherche une existante ou on la crée
      unless order
        order = current_user.orders.find_by(status: "en_attente") ||
                current_user.orders.create!(status: "en_attente")
        session[:order_id] = order.id # ✅ On la garde en mémoire
      end

      order
    else
      # 🔹 Utilisateur non connecté → gestion classique via session
      if session[:order_id]
        order = Order.find_by(id: session[:order_id], status: "en_attente")
        return order if order.present?
      end

      order = Order.create!(status: "en_attente")
      session[:order_id] = order.id
      order
    end
  end

  def clean_old_orders
    Order.where(status: "en_attente")
         .where("created_at < ?", 2.days.ago)
         .destroy_all
  end

  # ==============================================================
  # 🔐 Devise et layouts
  # ==============================================================

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name])
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(User) && resource.admin?
      rails_admin_path   # 🔹 Admin direct si admin
    else
      root_path          # 🔹 Sinon retour à la boutique
    end
  end

  private

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end
end
