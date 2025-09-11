class OrderItemsController < ApplicationController
  before_action :set_order

  def set_order
    @order = current_order
  end

  def create
    product = Product.find(order_item_params[:product_id])
    addons = Array(order_item_params[:addons]).join(', ')

    @order_item = @order.order_items.new(order_item_params.except(:addons))
    @order_item.addons = addons
    @order_item.price_cents = product.price_cents

    respond_to do |format|
      if @order_item.save
        format.html { redirect_to boutique_path, notice: "✅ #{product.name} ajouté au panier." }
        format.turbo_stream
      else
        format.html { redirect_to product_path(product), alert: "❌ Impossible d’ajouter le produit." }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flash") }
      end
    end
  end

    def destroy
      @order_item = @order.order_items.find(params[:id])
      @order_item.destroy
      redirect_to @order, notice: "Produit supprimé du panier."
    end

  private

  def order_item_params
    params.require(:order_item).permit(:product_id, :quantity, :color, :size, addons: [])
  end

   def set_order
    @order = Order.find(params[:order_id])
  end
end
