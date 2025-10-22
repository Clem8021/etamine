class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :clean_old_orders
  before_action :authorize_preview_or_redirect
  helper_method :current_order
  layout :layout_by_resource

  # ==============================================================
  # 🔒 Gestion du mode vitrine / prévisualisation client
  # ==============================================================

  private

  def authorize_preview_or_redirect
    return unless site_locked?

    # ✅ Si admin → accès complet
    return if current_user&.admin?

    # ✅ Si clé preview dans URL → on active la session preview
    if params[:key].to_s.strip == ENV["PREVIEW_KEY"].to_s.strip
      session[:preview_mode] = true
    end

    # ✅ Si preview active → accès total autorisé
    return if session[:preview_mode]

    # ✅ Pages autorisées sans clé
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

    # 🚫 Redirige si la page n’est pas dans la liste
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
      order = current_user.orders.find_by(id: session[:order_id], status: "en_attente")
      unless order
        order = current_user.orders.find_by(status: "en_attente") ||
                current_user.orders.create!(status: "en_attente")
        session[:order_id] = order.id
      end
      order
    else
      order = Order.find_by(id: session[:order_id], status: "en_attente")
      unless order
        order = Order.create!(status: "en_attente")
        session[:order_id] = order.id
      end
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
      rails_admin_path
    else
      root_path
    end
  end

  private

  def layout_by_resource
    devise_controller? ? "devise" : "application"
  end
end
