# app/models/delivery_detail.rb
class DeliveryDetail < ApplicationRecord
  belongs_to :order

  # === 🏘️ Liste des villages ===
  VILLAGES = [
    "Flesselles", "Naours", "Villers-Bocage", "Vaux-en-Amienois", "Bertangles", "Talmas", "Cardonettes",
    "Montonvillers", "Vignacourt", "Poulainville", "Rainneville", "Rubempré", "Hérissart",
    "Bernaville", "Candas", "Puchevillers", "Fienvillers", "Havernas", "Canaples", "Pernois",
    "Berteaucourt-les-Dames", "Beauval", "La Vicogne", "Molliens-au-Bois", "Coisy", "Mirvaux",
    "Saint-Vaast-en-Chaussée", "Autre (sur demande)"
  ].freeze

  # === ⚙️ Modes de réception ===
  MODES = %w[pickup delivery].freeze

  before_validation :set_default_mode
  validates :mode, inclusion: { in: MODES }

  # Helpers comme un enum
  def pickup? = mode == "pickup"
  def delivery? = mode == "delivery"

  # === 📝 Validations principales ===
  validates :mode, :date, :time_slot, presence: true
  validates :recipient_name, :recipient_phone, presence: true, if: :delivery?

  validate :no_same_day_delivery, if: :delivery?
  validate :pickup_delay, if: :pickup?

  # === ⚰️ Champs "deuil" obligatoires uniquement si commande de deuil ET livraison ===
  with_options if: -> { order&.products&.any? { |p| p.category == "deuil" } && delivery? } do
    validates :ceremony_date, :ceremony_time, :ceremony_location, presence: true
  end

  # === 🧹 Nettoyage automatique selon le mode ===
  before_validation :sanitize_by_mode

  # === 🚫 Livraison jour J interdite ===
  def no_same_day_delivery
    return unless date.present?
    if date == Date.current
      errors.add(:date, "❌ Livraison le jour même impossible en ligne. Merci de contacter la boutique.")
    end
  end

  # === ⏳ Délai minimum retrait ===
  def pickup_delay
    return unless date.present?
    if date == Date.current
      errors.add(:date, "⏳ Merci de prévoir un délai de 2h pour un retrait en magasin.")
    end
  end

  # === 💶 Frais de livraison ===
  def delivery_fee
    return 0 if pickup?

    if recipient_city == "Flesselles" && order.total_price >= 20
      0
    elsif recipient_city.present?
      350 # centimes = 3,50 €
    else
      0
    end
  end

  private

  # Définit un mode par défaut
  def set_default_mode
    self.mode ||= "pickup"
  end

  # Nettoie les champs inutiles selon le mode
  def sanitize_by_mode
    if pickup?
      self.recipient_name = nil
      self.recipient_firstname = nil
      self.recipient_address = nil
      self.recipient_zip = nil
      self.recipient_city = nil
      self.recipient_phone = nil
      self.ceremony_date = nil
      self.ceremony_time = nil
      self.ceremony_location = nil
    end
  end
end
