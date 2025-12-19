module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    def index
      @orders_today = Order.where(status: "payée")
                           .where(created_at: Time.zone.today.all_day)

      @orders_count = Order.where(status: "payée").count
      @revenue_today = @orders_today.sum(:total_cents) / 100.0
      @recent_orders = Order.where(status: "payée")
                             .order(created_at: :desc)
                             .limit(5)
    end

    private

    def require_admin!
      redirect_to root_path, alert: "Accès réservé à l’administrateur." unless current_user.admin?
    end
  end
end
