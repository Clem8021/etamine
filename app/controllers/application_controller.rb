class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :clean_old_orders

  # 🩷 Important : on vérifie la clé AVANT le verrouillage global
  before_action :authorize_preview!
  before_action :redirect_to_home_if_locked

  helper_method :current_order
  layout :layout_by_resource

  # ==============================================================
  # 🩷 MODE VITRINE (accès uniquement à certaines pages)
  # ==============================================================

  def redirect_to_home_if_locked
    return unless site_locked?

    allowed_routes = [
      { controller: "pages", action: "home" },
      { controller: "pages", action: "about" },
      { controller: "pages", action: "contact" },
      { controller: "pages", action: "cgv" },
      { controller: "rails", action: "active_storage" } # assets
    ]

    return if current_user&.admin?
    return if session[:preview_mode] # ✅ accès libre si mode preview actif

    unless allowed_routes.any? { |r| r[:controller] == controller_name && r[:action] == action_name }
      redirect_to root_path, notice: "🌸 Notre boutique est en préparation, revenez très bientôt !"
    end
  end

  def authorize_preview!
    if params[:key].to_s.strip == ENV["PREVIEW_KEY"].to_s.strip
      session[:preview_mode] = true
      Rails.logger.info "✅ Mode preview activé pour la session #{session.id}"
    end
  end

  def require_public_or_preview!
    unless session[:preview_mode] || params[:key].to_s.strip == ENV["PREVIEW_KEY"].to_s.strip
      redirect_to root_path, alert: "🚫 Accès restreint à la cliente uniquement."
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
      if session[:order_id]
        order = current_user.orders.find_by(id: session[:order_id], status: "en_attente")
      end
      unless order
        order = current_user.orders.find_by(status: "en_attente") ||
                current_user.orders.create!(status: "en_attente")
        session[:order_id] = order.id
      end
      order
    else
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
