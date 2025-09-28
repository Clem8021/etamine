class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  # ✅ plus besoin de redéclarer addons si la migration est bien array: true

  validates :quantity, :price_cents, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }

  # --- Addons (tableau postgres)
  def addon_list
    addons || []
  end

  # --- 💶 Prix total ---
  def total_price
    (price_cents * quantity) / 100.0
  end

  # --- Libellé complet (utile dans le panier) ---
  def display_name
    name = product.name
    name += " (#{color})" if color.present?
    name += " - #{size} roses" if size.present? && product.category == "roses"
    name += " - #{size}" if size.present? && product.category != "roses"
    name += " | #{addons.join(', ')}" if addons.present?
    name
  end

  # --- Prix unitaire affichable ---
  def unit_price
    price_cents / 100.0
  end
end
