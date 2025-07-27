class OrdersController < ApplicationController
  def new
    @order = Order.new
    @products = Product.all
  end

  def create
    @order = Order.new(order_params)
    total = 0

    order_items_params.each do |item|
      product = Product.find(item[:product_id])
      quantity = item[:quantity].to_i
      next if quantity.zero?

      price_cents = product.price_cents
      total += quantity * price_cents
      @order.order_items.build(product: product, quantity: quantity, price_cents: price_cents)
    end

    @order.total_cents = total

    if @order.save
      redirect_to @order, notice: "Commande créée avec succès !"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @order = Order.find(params[:id])
  end

  private

  def order_params
    params.require(:order).permit(:full_name, :email, :address)
  end

  def order_items_params
    params[:order_items] || []
  end
end
