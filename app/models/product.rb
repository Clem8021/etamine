class Product < ApplicationRecord
  CATEGORIES = %w[compositions roses orchidees deuil].freeze

  has_many :order_items
  has_many :orders, through: :order_items

  validates :name, :price_cents, :category, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :category, inclusion: { in: CATEGORIES }

  # --- 💶 Prix ---
  def price_cents
    self[:price_cents] || 0
  end

  def price_euros
    price_cents / 100.0
  end

  # --- Catégories ---
  def self.category_label(category)
    {
      "compositions" => "Compositions",
      "roses" => "Roses",
      "orchidees" => "Orchidées",
      "deuil" => "Deuil"
    }[category] || category.to_s.titleize
  end

  # --- Options ---
  def color_list
    color_options.to_s.split(',').map(&:strip)
  end

  def size_list
    size_options.to_s.split(',').map(&:strip)
  end

  def addon_list
    addons.to_s.split(',').map(&:strip)
  end

  # --- Prix par taille (fallback sur le prix de base) ---
  def price_for(size)
    if price_options.is_a?(Hash)
      price_options[size.to_s] || price_cents
    else
      price_cents
    end
  end
end
