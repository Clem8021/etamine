class DeliveryDetail < ApplicationRecord
  belongs_to :order

  # === 🏘️ Liste des villages ===
  VILLAGES = [
    "Flesselles", "Naours", "Villers-Bocage", "Vaux-en-Amienois", "Bertangles", "Talmas",
    "Cardonettes", "Montonvillers", "Vignacourt", "Poulainville", "Rainneville",
    "Rubempré", "Hérissart", "Bernaville", "Candas", "Puchevillers", "Fienvillers",
    "Havernas", "Canaples", "Pernois", "Berteaucourt-les-Dames", "Beauval",
    "La Vicogne", "Molliens-au-Bois", "Coisy", "Mirvaux",
    "Saint-Vaast-en-Chaussée", "Autre (sur demande)"
  ].freeze

  MODES = %w[pickup delivery].freeze

  before_validation :set_default_mode
  before_validation :sanitize_by_mode

  validates :mode, inclusion: { in: MODES }
  validates :mode, presence: true

  # ✅ TOUJOURS obligatoires
  validates :recipient_email,
            presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :recipient_phone,
            presence: true,
            if: :delivery?

  # 📅 TOUJOURS requis
  validates :date, :time_slot, presence: true

  # 🚚 Livraison uniquement
  with_options if: :delivery? do
    validates :recipient_name,
              :recipient_firstname,
              :recipient_address,
              :recipient_city,
              presence: true
  end

  # ⚰️ Deuil + livraison
  with_options if: -> { delivery? && order&.products&.any? { |p| p.category == "deuil" } } do
    validates :ceremony_date, :ceremony_time, :ceremony_location, presence: true
  end

  # === Contraintes métier ===
  validate :no_same_day_delivery, if: :delivery?
  validate :pickup_delay, if: :pickup?

  def pickup? = mode == "pickup"
  def delivery? = mode == "delivery"

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

  def set_default_mode
    self.mode ||= "pickup"
  end

  # 🧹 Nettoyage SANS casser email / téléphone
  def sanitize_by_mode
    return unless pickup?

    self.recipient_name = nil
    self.recipient_firstname = nil
    self.recipient_address = nil
    self.recipient_zip = nil
    self.recipient_city = nil

    self.ceremony_date = nil
    self.ceremony_time = nil
    self.ceremony_location = nil
  end

  def no_same_day_delivery
    return unless date.present?
    if date == Date.current
      errors.add(:date, "❌ Livraison le jour même impossible en ligne.")
    end
  end

  def pickup_delay
    return unless date.present?
    if date == Date.current
      errors.add(:date, "⏳ Merci de prévoir un délai minimum de 2h pour le retrait.")
    end
  end
end
