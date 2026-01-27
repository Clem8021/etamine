class MessageCardProduct < ApplicationRecord
  belongs_to :message_card
  belongs_to :product

  validates :message_card_id, uniqueness: { scope: :product_id }
end
