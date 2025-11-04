# app/controllers/order_items_controller.rb
class OrderItemsController < ApplicationController
  before_action :set_order

  ADDONS_PRICING = {
    "Gypsophile"     => 200,  # +2,00 €
    "Eucalyptus"     => 350,  # +3,50 €
    "Carte message"  => 150,  # +1,50 €
    "Ruban deuil"    => 700,  # +7,00 €
    "Bouquet bulle"  => 450   # +4,50 €
  }.freeze

  def create
    product      = Product.find(order_item_params[:product_id])
    quantity     = order_item_params[:quantity].to_i
    quantity     = 1 if quantity <= 0
    size         = order_item_params[:size]
    color        = order_item_params[:color]
    addons       = Array(order_item_params[:addons])
    addon_text   = order_item_params[:addon_text]   # si tu les utilises
    addon_type   = order_item_params[:addon_type]   # si tu les utilises

    # 💶 Prix unitaire de base (CENTIMES)
    base_cents = unit_price_cents_for(product, size)

    # ➕ Prix unitaire des addons (CENTIMES)
    addons_cents = addons.sum do |label|
      key = ADDONS_PRICING.keys.find { |k| label.to_s.include?(k) }
      key ? ADDONS_PRICING[key] : 0
    end

    # 💯 Prix TOTAL (CENTIMES) = (base + addons) * quantité
    total_cents = (base_cents + addons_cents) * quantity

    @order_item = @order.order_items.new(
      product:      product,
      quantity:     quantity,
      color:        color,
      size:         size,
      addons:       addons,
      addon_text:   addon_text,
      addon_type:   addon_type,
      price_cents:  total_cents # ✅ total en centimes
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
        format.json { render json: { success: false, errors: @order_item.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def update
    @order_item = @order.order_items.find(params[:id])
    if @order_item.update(order_item_params)
      redirect_to checkout_order_path(@order_item.order), notice: "Quantité mise à jour."
    else
      redirect_to checkout_order_path(@order_item.order), alert: "Impossible de modifier la quantité."
    end
  end

  def destroy
    @order_item = @order.order_items.find(params[:id])
    order = @order_item.order
    @order_item.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to checkout_order_path(order), notice: "Produit supprimé du panier." }
    end
  end

  private

  # ——— Trouve le prix unitaire (CENTIMES) selon le type de produit
  def unit_price_cents_for(product, size)
    # Cas 1 : produits avec menu de prix (customizable_price true)
    if product.customizable_price? && size.present?
      # price_options: { "30€" => 3000, ... } ou { "S" => 7000, ... }
      opt = product.price_options
      cents = opt.is_a?(Hash) ? opt[size] : nil
      return cents.to_i if cents.present?
    end

    # Cas 2 : roses avec paliers (price_options par libellé)
    if product.is_roses? && size.present?
      cents = product.price_options[size]
      return cents.to_i if cents.present?
    end

    # Cas 3 : prix fixe
    product.price_cents.to_i
  end

  def order_item_params
    params.require(:order_item).permit(
      :product_id,
      :quantity,
      :color,
      :size,
      :addon_text,       # si utilisé
      :addon_type,       # si utilisé
      addons: []
    )
  end

  def set_order
    @order = current_order
  end
end
