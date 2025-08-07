class ApplicationController < ActionController::Base
  helper_method :current_order

  def current_order
    @current_order ||= Order.find_or_create_by(id: session[:order_id], status: "pending").tap do |order|
      session[:order_id] = order.id
    end
  end
end
