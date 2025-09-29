class Product < ApplicationRecord
  CATEGORIES = %w[compositions roses deuil orchidees].freeze
  ROSE_VARIETIES = %w[explorer esperance avalanche].freeze

  has_many :order_items
  has_many :orders, through: :order_items

  validates :name, :price_cents, :category, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :category, inclusion: { in: CATEGORIES }
  validates :variety, inclusion: { in: ROSE_VARIETIES }, allow_nil: true

  # --- Roses spécifiques ---
  def is_roses?
    category == "roses"
  end
  # --- 💶 Prix ---
  def price_cents
    self[:price_cents] || 0
  end

  def price_euros
    price_cents / 100.0
  end

  # Prix à partir de (utile pour roses avec plusieurs tailles)
  def min_price_cents
    return price_cents if price_options.blank? || !price_options.is_a?(Hash)
    price_options.values.map(&:to_i).min
  end

  # --- Catégories ---
  def self.category_label(category)
    {
      "compositions" => "Compositions",
      "roses"        => "Roses",
      "orchidees"    => "Orchidées",
      "deuil"        => "Deuil"
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

  # --- Prix par taille/quantité ---
  def price_for(size)
    if price_options.is_a?(Hash)
      price_options[size.to_s] || price_cents
    else
      price_cents
    end
  end

  # --- Roses spécifiques ---
  def is_roses?
    category == "roses"
  end

  def available_colors
    is_roses? ? color_list : []
  end

  def available_quantities
    return [] unless is_roses? && price_options.is_a?(Hash)
    price_options.keys.map(&:to_i).sort
  end

 def display_image
    if image_url.present? && Rails.application.assets.find_asset(image_url)
      image_url
    else
      "placeholder.jpg" # une image par défaut à mettre dans app/assets/images/
    end
  end
end
