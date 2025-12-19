# app/controllers/admin/orders_controller.rb
class Admin::OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin

  def index
    @orders = Order.order(created_at: :desc)
  end

  def edit
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])
    if @order.update(order_params)
      redirect_to admin_orders_path, notice: "Commande mise à jour."
    else
      render :edit
    end
  end

  private

  def ensure_admin
    redirect_to root_path unless current_user.admin?
  end

  def order_params
    params.require(:order).permit(:status)
  end
end
