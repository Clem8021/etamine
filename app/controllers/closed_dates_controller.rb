# app/controllers/closed_dates_controller.rb
class ClosedDatesController < ApplicationController
  def index
    render json: ClosedDate.all.map { |d|
      { date: d.date.strftime("%Y-%m-%d"), label: d.label, recurring: d.recurring }
    }
  end
end
