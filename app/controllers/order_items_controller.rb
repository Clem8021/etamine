class OrderItemsController < ApplicationController
  before_action :set_order

  def create
    product  = Product.find(order_item_params[:product_id])
    quantity = order_item_params[:quantity].to_i
    size     = order_item_params[:size]
    color    = order_item_params[:color]
    addons   = Array(order_item_params[:addons])
    addon_text = order_item_params[:addon_text]
    addon_type = order_item_params[:addon_type]

    # 💶 Prix de base
    price_cents =
      if product.customizable_price? && size.present?
        # le menu déroulant envoie directement la valeur en centimes
        size.to_i
      elsif product.is_roses? && size.present?
        product.price_for(size).to_i
      else
        product.price_cents
      end

    # 💶 Ajout des options
    addons.each do |addon|
      case addon
      when /Gypsophile/ then price_cents += 200
      when /Eucalyptus/ then price_cents += 350
      when /Carte message/ then price_cents += 150
      when /Ruban deuil/ then price_cents += 700
      end
    end

    @order_item = @order.order_items.new(
      product: product,
      quantity: quantity,
      color: color,
      size: size,          # stocke le choix du menu (utile pour affichage)
      addons: addons,
      addon_text: addon_text,
      addon_type: addon_type,
      price_cents: price_cents
    )

    respond_to do |format|
      if @order_item.save
        format.html do
          redirect_to new_order_delivery_detail_path(@order),
            notice: "✅ #{product.name} ajouté au panier. Merci de renseigner les détails de livraison."
        end
        format.json do
          render json: {
            success: true,
            message: "✅ #{product.name} ajouté au panier",
            cart_item_count: @order.order_items.sum(:quantity)
          }
        end
        format.turbo_stream
      else
        format.html { redirect_to product_path(product), alert: "❌ Impossible d’ajouter." }
        format.json { render json: { success: false }, status: :unprocessable_entity }
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
    params.require(:order_item).permit(
      :product_id,
      :quantity,
      :color,
      :size,
      :addon_card,        # ✅ carte message activée ou non
      :addon_card_type,   # ✅ type de carte choisi
      :addon_card_text,   # ✅ texte du message ou ruban
      addons: []          # ✅ toujours garder pour tes options roses
    )
  end

  def set_order
    @order = current_order
  end
end
