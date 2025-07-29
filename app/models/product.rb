class Product < ApplicationRecord
  CATEGORIES = %w[compositions roses orchidees deuil].freeze

  has_many :order_items
  has_many :orders, through: :order_items

  validates :name, :price_cents, :stock_quantity, :category, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :category, inclusion: { in: CATEGORIES }

  def price_euros
    BigDecimal(price_cents) / 100
  end

   def self.category_label(category)
    {
      "compositions" => "Compositions",
      "roses" => "Roses",
      "orchidees" => "Orchidées",
      "deuil" => "Deuil"
    }[category] || category.titleize
  end

  def color_list
    color_options.to_s.split(',').map(&:strip)
  end

  def size_list
    size_options.to_s.split(',').map(&:strip)
  end

  def addon_list
    addons.to_s.split(',').map(&:strip)
  end
end
