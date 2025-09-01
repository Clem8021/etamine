class ApplicationController < ActionController::Base
  helper_method :current_order

  private

  def current_order
    if session[:order_id]
      order = Order.find_by(id: session[:order_id], status: "en_attente")
      return order if order.present?
    end

    # Crée un panier temporaire sans valider les autres champs
    order = Order.new(status: "en_attente")
    order.save(validate: false)
    session[:order_id] = order.id
    order
  end
end
