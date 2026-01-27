class MessageCardProduct < ApplicationRecord
  belongs_to :message_card
  belongs_to :product
end
