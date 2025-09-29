class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  has_one :delivery_detail, dependent: :destroy
  accepts_nested_attributes_for :delivery_detail
  belongs_to :user, optional: true
  accepts_nested_attributes_for :order_items

  STATUSES = %w[en_attente payée annulée expédiée].freeze
  validates :status, inclusion: { in: STATUSES }

  with_options unless: -> { status == 'en_attente' } do
    validates :full_name, :email, :address, presence: true
  end

  # --- 💶 Calculs de prix ---
  def total_price_cents
    order_items.includes(:product).inject(0) do |sum, item|
      base_price = item.product.price_for(item.size).to_i

      # ✅ Ajout du prix des options (addons)
      addons_price = 0
      if item.addons.present?
        addons_price += 200 if item.addons.include?("Gypsophile (+2€)")
        addons_price += 350 if item.addons.include?("Eucalyptus (+3,50€)")
        addons_price += 150 if item.addons.include?("Carte message")
        addons_price += 700 if item.addons.include?("Ruban deuil")
      end

      sum + (base_price + addons_price) * item.quantity
    end
  end

  def total_price
    total_price_cents / 100.0
  end

  def total_items
    order_items.sum(:quantity)
  end

  def delivery_complete?
    delivery_detail.present?
  end

  # --- Sous-total sans les frais de livraison ---
  def subtotal_cents
    total_price_cents
  end

  # --- Frais de livraison ---
  def delivery_fee_cents
    return 0 unless delivery_detail.present? && delivery_detail.delivery?

    city  = delivery_detail.recipient_city.to_s.strip.downcase
    flesselles = (city == "flesselles")

    if flesselles
      subtotal_cents >= 2000 ? 0 : 350
    else
      350
    end
  end

  # --- Total avec livraison ---
  def total_due_cents
    subtotal_cents + delivery_fee_cents
  end

  def total_due
    total_due_cents / 100.0
  end
end
