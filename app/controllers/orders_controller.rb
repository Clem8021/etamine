class OrdersController < ApplicationController
  def show
    @order = Order.find(params[:id])

    unless @order.delivery_complete?
      redirect_to new_order_delivery_detail_path(@order), alert: "Merci de compléter vos informations de livraison/retrait."
    end
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
      # après validation du paiement, on redirige obligatoirement vers la fiche
      redirect_to new_order_delivery_detail_path(@order)
    else
      render :new, status: :unprocessable_entity
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
