# app/models/message_card.rb
class MessageCard < ApplicationRecord
  has_many :message_card_products, dependent: :destroy
  has_many :products, through: :message_card_products

  scope :active, -> { where(is_active: true).order(:position, :name) }

  validates :name, presence: true
end
