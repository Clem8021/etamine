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
        format.html { redirect_to @order, notice: "Produit ajouté au panier." }
        format.json do
          render json: {
            success: true,
            cart_item_count: @order.total_items,
            message: "✅ #{product.name} ajouté au panier"
          }
        end
      else
        format.html { redirect_to product_path(product), alert: "Impossible d’ajouter le produit." }
        format.json do
          render json: {
            success: false,
            errors: @order_item.errors.full_messages,
            message: "❌ Impossible d’ajouter le produit."
          }, status: :unprocessable_entity
        end
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
