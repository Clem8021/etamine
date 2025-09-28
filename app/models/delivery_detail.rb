class DeliveryDetail < ApplicationRecord
  belongs_to :order

  VILLAGES = [
    "Naours",
    "Villers-Bocage",
    "Vaux-en-Amienois",
    "Bertangles",
    "Talmas",
    "Cardonettes",
    "Montonvillers",
    "Vignacourt",
    "Poulainville",
    "Rainneville",
    "Rubempré",
    "Hérissart",
    "Bernaville",
    "Candas",
    "Puchevillers",
    "Fienvillers",
    "Havernas",
    "Canaples",
    "Pernois",
    "Berteaucourt-les-Dames",
    "Beauval",
    "La Vicogne",
    "Molliens-au-Bois",
    "Coisy",
    "Mirvaux",
    "Saint-Vaast-en-Chaussée",
    "Autre (sur demande)"
  ].freeze

  validates :mode, :date, :time_slot, presence: true
  validates :recipient_name, :recipient_phone, presence: true, if: -> { mode == "delivery" }

  validate :no_same_day_delivery, if: -> { mode == "delivery" }
  validate :pickup_delay, if: -> { mode == "pickup" }

  with_options if: -> { order&.products&.any? { |p| p.category == "deuil" } } do
    validates :ceremony_date, :ceremony_time, :ceremony_location, presence: true
  end
  # === Validation personnalisée : livraison pas possible le jour J ===
  def no_same_day_delivery
    if date.present? && date == Date.today
      errors.add(:date, "❌ Livraison le jour même impossible en ligne. Merci de contacter le magasin.")
    end
  end

  # === Validation personnalisée : délai de 2h pour retrait magasin ===
  def pickup_delay
    if date.present? && date == Date.today && time_slot.present?
      # Ici tu pourrais affiner avec l’heure actuelle vs créneau choisi
      errors.add(:time_slot, "⏳ Merci de prévoir un délai de 2h pour un retrait en magasin.") if created_at && created_at > 2.hours.ago
    end
  end

  # === Frais de livraison ===
  def delivery_fee
    return 0 if mode == "pickup"

    if recipient_city == "Flesselles" && order.total_price >= 20
      0
    elsif recipient_city.present?
      350 # en centimes = 3,50€
    else
      0
    end
  end
end
