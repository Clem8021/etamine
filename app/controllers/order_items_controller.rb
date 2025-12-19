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

  # =========================================================
  # 🛒 AJOUT AU PANIER
  # =========================================================
  def create
    product  = Product.find(order_item_params[:product_id])
    quantity = order_item_params[:quantity].to_i
    quantity = 1 if quantity <= 0

    size   = order_item_params[:size]
    color  = order_item_params[:color]
    addons = Array(order_item_params[:addons])

    addon_card_type = order_item_params[:addon_card_type]
    addon_card_text = order_item_params[:addon_card_text]

    # =====================================================
    # 🔒 VALIDATIONS MÉTIER
    # =====================================================

    if product.is_roses? && size.blank?
      return redirect_to product_path(product),
        alert: "❌ Merci de choisir le nombre de roses."
    end

    if product.color_options.present? && color.blank?
      return redirect_to product_path(product),
        alert: "❌ Merci de choisir une couleur."
    end

    # =====================================================
    # 💶 CALCUL PRIX UNITAIRE (CENTIMES)
    # =====================================================

    base_cents = unit_price_cents_for(product, size)

    addons_cents = addons.sum do |label|
      key = ADDONS_PRICING.keys.find { |k| label.to_s.include?(k) }
      key ? ADDONS_PRICING[key] : 0
    end

    unit_cents = base_cents + addons_cents

    # =====================================================
    # 🧾 CRÉATION DE LA LIGNE
    # =====================================================

    @order_item = @order.order_items.new(
      product:         product,
      quantity:        quantity,
      color:           color,
      size:            size,
      addons:          addons,
      addon_card_type: addon_card_type.presence,
      addon_card_text: addon_card_text.presence,
      price_cents:     unit_cents # ✅ PRIX UNITAIRE UNIQUEMENT
    )

    respond_to do |format|
      if @order_item.save
        format.html do
          redirect_to checkout_order_path(@order),
            notice: "✅ #{product.name} ajouté au panier."
        end

        format.json do
          render json: {
            success: true,
            cart_item_count: @order.order_items.sum(:quantity)
          }
        end

        format.turbo_stream
      else
        format.html do
          redirect_to product_path(product),
            alert: @order_item.errors.full_messages.to_sentence
        end

        format.json do
          render json: {
            success: false,
            errors: @order_item.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
    end
  end

  # =========================================================
  # 🔄 MISE À JOUR DE LA QUANTITÉ
  # =========================================================
  def update
    @order_item = @order.order_items.find(params[:id])

    if @order_item.update(order_item_params)
      redirect_to checkout_order_path(@order),
        notice: "Quantité mise à jour."
    else
      redirect_to checkout_order_path(@order),
        alert: "Impossible de modifier la quantité."
    end
  end

  # =========================================================
  # ❌ SUPPRESSION
  # =========================================================
  def destroy
    @order_item = @order.order_items.find(params[:id])
    order = @order_item.order

    @order_item.destroy

    respond_to do |format|
      format.turbo_stream
      format.html do
        redirect_to checkout_order_path(order),
          notice: "Produit supprimé du panier."
      end
    end
  end

  private

  # =========================================================
  # 💶 PRIX UNITAIRE (CENTIMES)
  # =========================================================
  def unit_price_cents_for(product, size)
    if product.category == "roses" && size.present?
      return product.price_options[size].to_i
    end
    product.price_cents.to_i

    # 🌹 Roses avec paliers
    if product.is_roses? && size.present?
      return product.price_options[size].to_i
    end

    # 💐 Prix fixe
    product.price_cents.to_i
  end

  # =========================================================
  # 🔐 PARAMÈTRES AUTORISÉS
  # =========================================================
  def order_item_params
    params.require(:order_item).permit(
      :product_id,
      :quantity,
      :color,
      :size,
      :addon_card_type,
      :addon_card_text,
      addons: []
    )
  end

  def set_order
    @order = current_order
  end
end
