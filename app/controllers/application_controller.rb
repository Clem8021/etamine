class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :clean_old_orders
  helper_method :current_order
  layout :layout_by_resource

  private

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
