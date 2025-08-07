class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  accepts_nested_attributes_for :order_items

  validates :full_name, :email, :address, presence: true

  STATUSES = %w[en_attente payée annulée expédiée].freeze
  validates :status, inclusion: { in: STATUSES }

  def total_price
    order_items.includes(:product).inject(0) do |sum, item|
      sum + item.product.price_euros * item.quantity
    end
  end
end
