module Backoffice
  class AvailableDatesController < ApplicationController

    def index
      @available_dates = AvailableDate.order(date: :asc)
      @available_date = AvailableDate.new
    end

    def show
      @available_date = AvailableDate.find_by(date: params[:id])
    end

    def create
      @available_date = AvailableDate.find_or_initialize_by(date: available_date_params[:date])
      @available_date.assign_attributes(available_date_params)

      if @available_date.save
        head :ok
      else
        render json: { errors: @available_date.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update_by_date
      @available_date = AvailableDate.find_by(date: params[:date])
      @available_date&.update(time_slot: params[:time_slot])
      head :ok
    end

    def destroy
      @available_date = AvailableDate.find_by(date: params[:id])
      @available_date&.destroy
      head :ok
    end

    private

    def available_date_params
      params.require(:available_date).permit(:date, :mode, :time_slot)
    end
  end
end
