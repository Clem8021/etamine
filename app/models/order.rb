class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  has_one :delivery_detail, dependent: :destroy
  accepts_nested_attributes_for :delivery_detail
  belongs_to :user
  accepts_nested_attributes_for :order_items

  STATUSES = %w[en_attente payée annulée expédiée].freeze
  validates :status, inclusion: { in: STATUSES }

  # ✅ Ne valide les champs que si la commande est dans un état autre que "en_attente"
  with_options unless: -> { status == 'en_attente' } do
    validates :full_name, :email, :address, presence: true
  end

  # --- 💶 Prix en centimes (pour Stripe) ---
  def total_price_cents
    order_items.includes(:product).inject(0) do |sum, item|
      sum + item.product.price_cents * item.quantity
    end
  end

  # --- 💶 Prix en euros (pour affichage) ---
  def total_price
    total_price_cents / 100.0
  end

  # Retourne le nombre total d'articles dans le panier
  def total_items
    order_items.sum(:quantity)
  end

  # si tu veux bloquer la commande sans fiche
  def delivery_complete?
    delivery_detail.present?
  end
end
