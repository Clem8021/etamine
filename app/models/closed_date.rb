# app/models/closed_date.rb
class ClosedDate < ApplicationRecord
  validates :date, presence: true
  validates :label, presence: true
end
