class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :clean_old_orders
  before_action :flag_shop_closed

  helper_method :current_order

  layout :layout_by_resource

  # ==============================================================
  # 🛒 Gestion du panier / commande
  # ==============================================================


  def flag_shop_closed
    return if current_user&.admin?

    blocked_paths = [
      "/boutique",
      "/orders",
      "/cart",
      "/panier",
      "/mariage",
    ]

    @shop_closed = blocked_paths.any? { |path| request.path.start_with?(path) }
  end

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
  # 🔐 Devise / strong params
  # ==============================================================

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,        keys: [:first_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name])
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(Admin)
      backoffice_root_path
    else
      root_path
    end
  end

  private

  def layout_by_resource
    devise_controller? ? "devise" : "application"
  end

  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Accès réservé à l’administrateur."
    end
  end
end
