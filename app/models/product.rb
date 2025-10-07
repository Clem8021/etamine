class Product < ApplicationRecord
  CATEGORIES = %w[compositions roses deuil orchidees].freeze
  ROSE_VARIETIES = %w[explorer esperance avalanche].freeze

  has_many :order_items
  has_many :orders, through: :order_items

  validates :name, :category, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :variety, inclusion: { in: ROSE_VARIETIES }, allow_nil: true

  # --- Roses spécifiques ---
  def is_roses?
    category == "roses"
  end

  # --- 💶 Prix intelligent ---
  def price_cents
    value = self[:price_cents]
    return value if value.present? && value > 0

    # Fallback sur les options de prix (ex: roses ou compositions personnalisables)
    if price_options.is_a?(Hash) && price_options.values.any?
      price_options.values.compact.map(&:to_i).min
    else
      0
    end
  end

  def price_euros
    price_cents.to_f / 100
  end

  # --- Prix minimum (utile pour l’affichage “À partir de...”) ---
  def min_price_cents
    if price_options.is_a?(Hash) && price_options.values.any?
      price_options.values.map(&:to_i).min
    else
      price_cents
    end
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

  # --- Options de sélection ---
  def color_list
    color_options.to_s.split(',').map(&:strip)
  end

  def size_list
    size_options.to_s.split(',').map(&:strip)
  end

  def addon_list
    addons.to_s.split(',').map(&:strip)
  end

  # --- Prix selon la taille / quantité ---
  def price_for(size)
    if price_options.is_a?(Hash)
      price_options[size.to_s].to_i.nonzero? || price_cents
    else
      price_cents
    end
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
      "placeholder.jpg"
    end
  end
end
