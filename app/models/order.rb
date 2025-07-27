class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  accepts_nested_attributes_for :order_items

  validates :full_name, :email, :address, presence: true

  STATUSES = %w[en_attente payée annulée expédiée].freeze
  validates :status, inclusion: { in: STATUSES }

  def total_price_euros
    total_cents / 100.0
  end
end
