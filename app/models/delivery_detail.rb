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
end
