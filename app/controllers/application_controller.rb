class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :clean_old_orders

  helper_method :current_order, :preview_mode?
  layout :layout_by_resource

  # ==============================================================
  # 🔓 Mode "preview" pour certaines pages (mariage, galerie, etc.)
  # ==============================================================

  private

  # Utilisable dans les autres contrôleurs :
  # before_action :require_preview_access, only: [:mariage_fleuriste, ...]
  def require_preview_access
    # Admin → accès complet
    return if current_user&.admin?

    # Clé de prévisualisation dans l’URL ?key=XXX
    if params[:key].to_s == ENV["PREVIEW_KEY"].to_s
      session[:preview_mode] = true
      return
    end

    # Session déjà en mode preview
    return if preview_mode?

    # Sinon → refus
    redirect_to root_path, notice: "🌸 Cette page est encore en préparation."
  end

  def preview_mode?
    session[:preview_mode] == true
  end

  # ==============================================================
  # 🛒 Gestion du panier / commandes invité + connecté
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
  # 🔐 Devise + layouts
  # ==============================================================

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,        keys: [:first_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name])
  end

  private

  def after_sign_in_path_for(resource)
    if resource.is_a?(User) && resource.admin?
      rails_admin_path
    else
      root_path
    end
  end

  def layout_by_resource
    devise_controller? ? "devise" : "application"
  end
end
