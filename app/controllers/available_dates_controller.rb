# app/controllers/available_dates_controller.rb
class AvailableDatesController < ApplicationController
  def index
    render json: AvailableDate.all.map { |d|
      { date: d.date.strftime("%Y-%m-%d"), time_slot: d.time_slot }
    }
  end
end
