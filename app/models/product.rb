class Product < ApplicationRecord
  CATEGORIES = %w[bouquets compositions roses deuil orchidees saint-valentin].freeze
  ROSE_VARIETIES = %w[rouge rose blanche].freeze

  has_many :order_items, dependent: :restrict_with_error
  has_many :orders, through: :order_items

  validates :name, :category, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :variety, inclusion: { in: ROSE_VARIETIES }, allow_nil: true, allow_blank: true

  has_one_attached :photo

  scope :active, -> { where(active: true) }
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
      "bouquets" => "Bouquets",
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
    # 1) image principale si présente
    return image_url if image_url.present?

    # 2) fallback: première image d’un hash couleur -> image
    if color_options.is_a?(Hash) && color_options.values.any?
      return color_options.values.first
    end

    # 3) fallback final
    "placeholder.jpg"
  end

  def display_image_url
    filename =
      if image_url.present?
        image_url
      elsif color_options.is_a?(Hash) && color_options.values.any?
        color_options.values.first
      else
        "placeholder.jpg"
      end

    return filename if filename.start_with?("http://", "https://", "/")
    ActionController::Base.helpers.asset_path(filename)
  end

  def gallery
    # 0) Photo uploadée via ActiveStorage (prioritaire)
    if photo.attached?
      return [photo]
    end

    # 1) Galerie en base (si tu en as)
    if respond_to?(:gallery_images) && gallery_images.is_a?(Array) && gallery_images.any?
      return gallery_images
    end

    # 2) image_url
    if image_url.present?
      return [image_url]
    end

    # 3) couleurs hash => liste des images
    if color_options.is_a?(Hash) && color_options.values.any?
      return color_options.values
    end

    ["placeholder.jpg"]
  end

  def carousel?
    gallery.size > 1
  end

  def starting_price_cents
    if price_options.is_a?(Hash) && price_options.values.any?
      price_options.values.map(&:to_i).min
    else
      price_cents.to_i
    end
  end
end
