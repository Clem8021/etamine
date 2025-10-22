class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :clean_old_orders
  before_action :authorize_preview_or_redirect
  helper_method :current_order
  layout :layout_by_resource

  private

  # ==============================================================
  # 🔒 Gestion du mode vitrine / prévisualisation client
  # ==============================================================

  def authorize_preview_or_redirect
    # 🔹 Si le site n’est pas verrouillé → accès normal
    return unless site_locked?

    # 🔹 Si la session preview est active → accès total autorisé
    return if session[:preview_mode]

    # 🔹 Si la clé est fournie dans l’URL → on active la preview
    if params[:key].to_s.strip == ENV["PREVIEW_KEY"].to_s.strip
      session[:preview_mode] = true
      return
    end

    # 🔹 Autorise certaines pages même en mode verrouillé
    allowed_routes = [
      { controller: "pages", action: "home" },
      { controller: "pages", action: "about" },
      { controller: "pages", action: "contact" },
      { controller: "pages", action: "cgv" },
      { controller: "products", action: "preview" },
      { controller: "products", action: "index" },
      { controller: "products", action: "show" },
      { controller: "orders", action: "checkout" },
      { controller: "orders", action: "confirm" },
      { controller: "orders", action: "success" }
    ]

    # 🔓 Les administrateurs contournent toujours le verrou
    return if current_user&.admin?

    # 🚫 Blocage des routes non autorisées
    unless allowed_routes.any? { |r| r[:controller] == controller_name && r[:action] == action_name }
      redirect_to root_path, notice: "🌸 Notre boutique est en préparation, revenez très bientôt !"
    end
  end

  def site_locked?
    true
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
      # 🔹 Utilisateur non connecté → gestion via session uniquement
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
