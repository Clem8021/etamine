class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  # ✅ Validations de base
  validates :quantity, :price_cents, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :size, presence: true, if: :roses?

  # 🔥 Couleur obligatoire SI le produit a des couleurs
  validates :color, presence: true, if: :product_has_colors?

  # === CALLBACKS ===
  after_save :update_order_total
  after_destroy :update_order_total

  # === ADDONS ===
  def addon_list
    addons || []
  end

  # --- 💶 Prix unitaire (en euros) ---
  def unit_price
    price_cents.to_f / 100
  end

  # --- 💶 Prix total de la ligne ---
  def total_price
    (price_cents.to_i * quantity.to_i) / 100.0
  end

  # --- 🔹 Nom affichable ---
  def display_name
    name = product.name
    name += " (#{color})" if color.present?
    name += " - #{size} roses" if size.present? && product.category == "roses"
    name += " - #{size}" if size.present? && product.category != "roses"
    name += " | #{addons.join(', ')}" if addons.present?
    name
  end

  # --- 💰 Définit un prix s’il n’est pas encore défini ---
  def set_price_cents
    return if price_cents.present?

    base_price = product.price_for(size).to_i

    addons_price = 0
    if addons.present?
      addons_price += 200 if addons.include?("Gypsophile (+2€)")
      addons_price += 350 if addons.include?("Eucalyptus (+3,50€)")
      addons_price += 150 if addons.include?("Carte message")
      addons_price += 700 if addons.include?("Ruban deuil")
    end

    self.price_cents = base_price + addons_price
  end

  private

  # 🔐 Condition pour la validation couleur
  def product_has_colors?
    product.present? && product.color_options.present?
  end

  # === 🧾 Recalcul du total de la commande ===
  def update_order_total
    order.update(total_cents: order.order_items.sum('price_cents * quantity'))
  end
end
