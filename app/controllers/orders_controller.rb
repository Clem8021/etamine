class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @order = current_user.orders.new(order_params)
  end

  def create
    @order = current_user.orders.new(order_params)

    if @order.save
      redirect_to @order, notice: "Commande créée avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @order = current_user.orders.find_by(id: params[:id])

    if @order.nil?
      redirect_to boutique_path, alert: "Cette commande n'existe pas ou ne vous appartient pas."
      return
    end

    unless @order.delivery_complete?
      redirect_to new_order_delivery_detail_path(@order), alert: "Merci de compléter vos informations de livraison/retrait."
    end
  end

  def checkout
    @order = current_user.orders.find(params[:id])

    if @order.order_items.empty?
      redirect_to boutique_path, alert: "Votre panier est vide."
    end
  end

  def confirm
    @order = current_user.orders.find(params[:id])
    @order.status = "paid"
    @order.total_cents = @order.total_price_cents

    if @order.save
      redirect_to @order, notice: "✅ Commande confirmée et payée."
    else
      render :checkout, status: :unprocessable_entity
    end
  end

  def cart
    @order = current_order
  end

  def confirm
    @order = current_order
    if @order.update(status: "paid", total_cents: @order.total_price_cents)
      session[:order_id] = nil
      redirect_to @order, notice: "🎉 Merci pour votre commande !"
    else
      redirect_to checkout_path(order_id: @order.id), alert: "Une erreur est survenue."
    end
  end

  private

  def order_params
    params.require(:order).permit(:full_name, :email, :address)
  end
end
