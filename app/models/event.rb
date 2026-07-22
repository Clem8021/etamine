class Event < ApplicationRecord
  has_many_attached :photos

  validates :title, presence: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(event_date: :desc) }

  def cover_photo
    photos.first
  end

  # Variant optimisé pour l'affichage web (redimensionné + compressé)
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
end