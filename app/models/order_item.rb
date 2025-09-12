class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, :price_cents, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }

  def total_price
    (price_cents * quantity) / 100.0
  end
end
