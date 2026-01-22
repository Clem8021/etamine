class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, :price_cents, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :size, presence: true, if: :roses?
  validates :color, presence: true, if: :product_has_colors?

  before_validation :normalize_addons
  before_validation :sync_card_and_ribbon_from_addons
  before_validation :set_price_cents, on: :create

  after_save :update_order_total
  after_destroy :update_order_total

  def roses?
    product&.category == "roses"
  end

  # ✅ Toujours une liste (Array) quel que soit le format stocké
  def addon_list
    case self.addons
    when Array
      self.addons
    when String
      self.addons.split(",").map(&:strip).reject(&:blank?)
    else
      []
    end
  end

  def unit_price
    price_cents.to_f / 100
  end

  def total_price
    (price_cents.to_i * quantity.to_i) / 100.0
  end

  def display_name
    name = product.name
    name += " (#{color})" if color.present?
    name += " - #{size} roses" if size.present? && product.category == "roses"
    name += " - #{size}" if size.present? && product.category != "roses"
    name += " | #{addon_list.join(', ')}" if addon_list.any?
    name
  end

  def set_price_cents
    return if price_cents.present?

    base_price = product.price_for(size).to_i

    addons_price = 0
    list = addon_list

    addons_price += 200 if list.any? { |a| a.include?("Gypsophile (+2€)") }
    addons_price += 350 if list.any? { |a| a.include?("Eucalyptus (+3,50€)") }
    addons_price += 150 if list.any? { |a| a.include?("Carte message") }
    addons_price += 700 if list.any? { |a| a.include?("Ruban deuil") }

    self.price_cents = base_price + addons_price
  end

  private

  def normalize_addons
    # 🔒 On stocke toujours un string "propre" en DB (si ta colonne est text)
    self.addons = addon_list.join(", ")
  end

  def sync_card_and_ribbon_from_addons
    list = addon_list.map(&:downcase)

    # Si on n’a pas explicitement coché, on déduit du texte
    self.addon_card = true if addon_card.nil? && list.any? { |a| a.include?("carte") }
    self.addon_ruban = true if addon_ruban.nil? && list.any? { |a| a.include?("ruban") }

    # Optionnel : si carte cochée mais pas de type, on met un défaut
    if addon_card == true && respond_to?(:addon_card_type) && addon_card_type.blank?
      self.addon_card_type = "Carte message"
    end
  end

  def product_has_colors?
    product.present? && product.color_options.present?
  end

  def update_order_total
    order.update(total_cents: order.order_items.sum("price_cents * quantity"))
  end
end
