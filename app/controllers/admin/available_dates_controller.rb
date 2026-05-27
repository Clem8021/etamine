class Admin::AvailableDatesController < ApplicationController
  before_action :set_available_date, only: [:destroy]

  def index
    @available_dates = AvailableDate.order(:date)
    @available_date = AvailableDate.new
  end

  def create
    @available_date = AvailableDate.new(available_date_params)

    if @available_date.save
      redirect_to admin_available_dates_path, notice: "Date ajoutée."
    else
      @available_dates = AvailableDate.order(:date)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @available_date.destroy
    redirect_to admin_available_dates_path, notice: "Date supprimée."
  end

  private

  def set_available_date
    @available_date = AvailableDate.find(params[:id])
  end

  def available_date_params
    params.require(:available_date).permit(:date)
  end
end
