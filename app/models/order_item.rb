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

  def set_price_cents
    return if price_cents.present? # évite d’écraser si déjà défini

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

  # Prix total de la ligne (unit price × quantity)
  def total_cents
    price_cents.to_i * quantity.to_i
  end
end
