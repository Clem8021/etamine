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

  def pickup? = mode == "pickup"
  def delivery? = mode == "delivery"

  # === 📝 Validations dépendantes du mode ===

  # Champs requis dans TOUS les cas
  validates :mode, presence: true

  # Champs requis UNIQUEMENT pour la livraison
  with_options if: :delivery? do
    validates :date, :time_slot, presence: true
    validates :recipient_name, :recipient_phone, presence: true
  end

  # === 🔥 Contraintes spécifiques ===
  validate :no_same_day_delivery, if: :delivery?
  validate :pickup_delay, if: :pickup?

  # === ⚰️ Champs "deuil" obligatoires uniquement si produit de deuil *et* livraison
  with_options if: -> { delivery? && order&.products&.any? { |p| p.category == "deuil" } } do
    validates :ceremony_date, :ceremony_time, :ceremony_location, presence: true
  end

  # === 🧹 Nettoyage automatique selon le mode ===
  before_validation :sanitize_by_mode

  # === 💶 Frais de livraison ===
  def delivery_fee
    return 0 if pickup?

    if recipient_city == "Flesselles" && order.total_price >= 20
      0
    elsif recipient_city.present?
      350
    else
      0
    end
  end

  private

  def no_same_day_delivery
    return unless date.present?
    errors.add(:date, "❌ Livraison le jour même impossible en ligne. Merci de contacter la boutique.") if date == Date.current
  end

  def pickup_delay
    return unless date.present?
    errors.add(:date, "⏳ Merci de prévoir un délai de 2h pour un retrait en magasin.") if date == Date.current
  end

  def set_default_mode
    self.mode ||= "pickup"
  end

  # Nettoyage automatique pour éviter erreurs → indispensable pour Stripe tests & flux invité
  def sanitize_by_mode
    return unless pickup?

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
