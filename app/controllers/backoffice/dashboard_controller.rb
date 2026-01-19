class Backoffice::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    # Les 5 dernières commandes payées
    @recent_paid_orders = Order
      .where(status: "payée")
      .order(created_at: :desc)

    # Nombre total de commandes payées
    @paid_orders_count = Order.where(status: "payée").count

    # Nombre total de commandes (tous statuts)
    @orders_count = Order.count
  end

  private

  def require_admin!
    authenticate_admin!
  end
end
