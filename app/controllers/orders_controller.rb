class OrdersController < ApplicationController
  def show
    @order = current_order
  end

  def checkout
    @order = current_order
    @order.assign_attributes(order_params)

    if @order.order_items.empty?
      redirect_to boutique_path, alert: "Votre panier est vide."
      return
    end

    @order.status = "paid" # ou "pending" selon logique
    @order.total_cents = @order.total_price_cents

    if @order.save
      session[:order_id] = nil # vide le panier
      redirect_to @order, notice: "Merci pour votre commande !"
    else
      render :show, status: :unprocessable_entity
    end
  end

  def cart
    @order = current_order
  end

  private

  def order_params
    params.require(:order).permit(:full_name, :email, :address)
  end
end
