class OrderItemsController < ApplicationController
  def create
    @order = current_order
    product = Product.find(params[:product_id])
    addons = Array(params[:addons]).join(', ')

    @order_item = @order.order_items.new(
      product: product,
      quantity: params[:quantity],
      price_cents: product.price_cents,
      color: params[:color],
      size: params[:size],
      addons: addons
    )

    if @order_item.save
      redirect_to @order, notice: "Produit ajouté au panier."
    else
      redirect_to product_path(product), alert: "Impossible d’ajouter le produit."
    end
  end

  def order_item_params
    params.require(:order_item).permit(:product_id, :quantity, :color, :size, :addons)
  end
end
