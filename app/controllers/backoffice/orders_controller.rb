module Backoffice
  class OrdersController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    def index
      @orders = Order
        .where(status: "payée")
        .order(created_at: :desc)
    end

    def show
      @order = Order.find(params[:id])
    end

    def update
      @order = Order.find(params[:id])

      if @order.update(order_params)
        redirect_to backoffice_order_path(@order),
          notice: "Commande mise à jour"
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def order_params
      params.require(:order).permit(:status)
    end
  end
end
