class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :current_order
  layout :layout_by_resource

  private

  def current_order
    if user_signed_in?
      # 🔹 Si l’utilisateur est connecté → récupère ou crée son panier
      current_user.orders.find_or_create_by(status: "en_attente")
    else
      # 🔹 Si invité → utilise la session
      if session[:order_id]
        order = Order.find_by(id: session[:order_id], status: "en_attente")
        return order if order.present?
      end

      # 🔹 Sinon → crée un panier temporaire invité
      order = Order.create!(status: "en_attente") # user_id = nil grâce à `optional: true`
      session[:order_id] = order.id
      order
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name])
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
