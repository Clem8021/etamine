class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :clean_old_orders
  before_action :authorize_preview_or_redirect
  helper_method :current_order, :preview_mode?
  layout :layout_by_resource

  private

  # === Mode vitrine / preview ===
  def preview_mode?
    session[:preview_mode] == true
  end

  def authorize_preview_or_redirect
    return unless site_locked?

    # Admins : accès total
    return if current_user&:admin?

    # Clé preview -> active la session
    if params[:key].to_s.strip == ENV["PREVIEW_KEY"].to_s.strip
      session[:preview_mode] = true
    end

    # Si preview active -> accès total
    return if preview_mode?

    # Pages publiques sans clé (ne PAS mettre checkout/confirm/success ici)
    allowed_routes = [
      { controller: "pages",    action: "home" },
      { controller: "pages",    action: "about" },
      { controller: "pages",    action: "contact" },
      { controller: "pages",    action: "cgv" },
      # la page qui sert à activer la preview :
      { controller: "products", action: "preview" }
    ]

    unless allowed_routes.any? { |r| r[:controller] == controller_name && r[:action] == action_name }
      redirect_to root_path, notice: "🌸 Notre boutique est en préparation, revenez très bientôt !"
    end
  end

  def site_locked?
    true
  end

  # === Panier / commande (ok)
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

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name])
  end

  private

  def after_sign_in_path_for(resource)
    resource.is_a?(User) && resource.admin? ? rails_admin_path : root_path
  end

  def layout_by_resource
    devise_controller? ? "devise" : "application"
  end
end
