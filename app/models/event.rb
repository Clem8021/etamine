class Event < ApplicationRecord
  has_many_attached :photos
  serialize :featured_photo_ids, coder: JSON

  validates :title, presence: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(event_date: :desc) }

  before_save :normalize_featured_photo_ids

  def cover_photo
    featured_photos.first || photos.first
  end

  def featured?(photo)
    Array(featured_photo_ids).include?(photo.id.to_s)
  end

  def featured_photos
    ids = Array(featured_photo_ids)
    return [] if ids.empty?

    photos.to_a.select { |p| ids.include?(p.id.to_s) }
  end

  # Photos mises en avant en premier, puis le reste — utilisé pour l'affichage public
  def ordered_photos
    featured = featured_photos
    rest = photos.to_a - featured
    featured + rest
  end

  def self.web_variant(photo)
    photo.variant(
      resize_to_limit: [1600, 1600],
      saver: { quality: 80, strip: true }
    )
  end

  def self.thumb_variant(photo)
    photo.variant(
      resize_to_limit: [500, 500],
      saver: { quality: 70, strip: true }
    )
  end

  private

  def normalize_featured_photo_ids
    self.featured_photo_ids = Array(featured_photo_ids).reject(&:blank?).uniq.first(3)
  end
end