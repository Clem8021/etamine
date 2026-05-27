# app/controllers/backoffice/closed_dates_controller.rb
class Backoffice::ClosedDatesController < ApplicationController
  def index
    @closed_dates = ClosedDate.order(:date)
  end

  def create
    @closed_date = ClosedDate.new(closed_date_params)
    if @closed_date.save
      redirect_to backoffice_closed_dates_path, notice: "Date ajoutée."
    else
      redirect_to backoffice_closed_dates_path, alert: "Erreur."
    end
  end

  def destroy
    ClosedDate.find(params[:id]).destroy
    redirect_to backoffice_closed_dates_path, notice: "Date supprimée."
  end

  private

  def closed_date_params
    params.require(:closed_date).permit(:date, :label, :recurring)
  end
end
