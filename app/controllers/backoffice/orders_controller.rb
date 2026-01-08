module Backoffice
  class OrdersController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    def index
      @orders = Order.active
                    .where(status: "payée")
                    .order(created_at: :desc)

      @archived_orders = Order.archived
                            .where(status: "payée")
                            .order(archived_at: :desc)
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

    def destroy
      @order = Order.find(params[:id])
      @order.archive!
      redirect_to backoffice_orders_path, notice: "Commande supprimée."
    end

    private

    def order_params
      params.require(:order).permit(:status)
    end

    def archived
      @orders = Order.archived.order(archived_at: :desc)
    end

    def unarchive
      @order = Order.find(params[:id])
      @order.unarchive!
      redirect_to archived_backoffice_orders_path,
                  notice: "Commande restaurée."
    end
  end
end
