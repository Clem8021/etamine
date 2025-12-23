class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :clean_old_orders, unless: -> { Rails.env.production? }

  helper_method :current_order

  layout :layout_by_resource

  # ==============================================================
  # 🛒 Gestion du panier / commande
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
  # 🔐 Devise
  # ==============================================================

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name])
  end

  def after_sign_in_path_for(resource)
    resource.is_a?(Admin) ? backoffice_root_path : root_path
  end

  private

  def layout_by_resource
    devise_controller? ? "devise" : "application"
  end

  def require_admin!
    redirect_to root_path, alert: "Accès réservé à l’administrateur." unless current_user&.admin?
  end
end
