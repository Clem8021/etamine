class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @orders = Order.all.order(created_at: :desc)

    if params[:status].present?
      @orders = @orders.where(status: params[:status])
    end
  end

  def create
    @order = current_user.orders.new(order_params.merge(status: "en_attente"))

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
    else
      # Ici tu rends une vue récap
      render :checkout
    end
  end

  def cart
    @order = current_order
  end

  def confirm
    @order = current_user.orders.find(params[:id])

    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: @order.order_items.map do |item|
        {
          price_data: {
            currency: 'eur',
            product_data: { name: item.product.name },
            unit_amount: item.price_cents
          },
          quantity: item.quantity
        }
      end,
      mode: 'payment',
      success_url: order_url(@order),
      cancel_url: panier_url
    )

    redirect_to session.url, allow_other_host: true
  end

  private

  def order_params
    params.require(:order).permit(:full_name, :email, :address)
  end
end
