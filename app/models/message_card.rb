class MessageCard < ApplicationRecord
  has_many :message_card_products, dependent: :destroy
  has_many :products, through: :message_card_products

  validates :name, presence: true, uniqueness: true
end
