class Order < ApplicationRecord
  # --- Associations ---
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  has_one :delivery_detail, dependent: :destroy
  accepts_nested_attributes_for :delivery_detail
  belongs_to :user, optional: true
  accepts_nested_attributes_for :order_items
  validates :phone_number,
  format: { with: /\A0[1-9](\s?\d{2}){4}\z/,
            message: "doit être un numéro valide (ex : 06 12 34 56 78)" },
  unless: -> { status == "en_attente" }

  # --- Statuts ---
  STATUSES = %w[en_attente payée annulée expédiée].freeze
  validates :status, inclusion: { in: STATUSES }

  # ❌ IMPORTANT : On ne valide *pas* full_name / email / address ici,
  # car le vrai formulaire client utilise DeliveryDetail.
  # Ces champs peuvent rester nil pour Stripe test → évite RecordInvalid.

  # --- 💶 Calculs de prix ---
  def total_price_cents
    order_items.includes(:product).inject(0) do |sum, item|
      base_price = item.product.price_for(item.size).to_i

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

  # --- Livraison ---
  def delivery_complete?
    delivery_detail.present?
  end

  def subtotal_cents
    total_price_cents
  end

  def delivery_fee_cents
    return 0 unless delivery_detail.present? && delivery_detail.mode == "delivery"

    city = delivery_detail.recipient_city.to_s.strip.downcase
    flesselles = (city == "flesselles")

    if flesselles && subtotal_cents >= 2000
      0 # livraison gratuite Flesselles si ≥ 20€
    else
      350
    end
  end

  def total_due_cents
    subtotal_cents + delivery_fee_cents
  end

  def total_due
    total_due_cents / 100.0
  end

  def clear_delivery_info
    delivery_detail&.destroy
  end
end
