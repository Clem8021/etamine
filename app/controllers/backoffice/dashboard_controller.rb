module Backoffice
  class DashboardController < BaseController
    def index
      @recent_paid_orders = Order
        .where(status: "payée")
        .order(created_at: :desc)

      @paid_orders_count = Order.where(status: "payée").count
      @orders_count = Order.count
    end
  end
end
