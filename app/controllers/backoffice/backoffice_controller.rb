# app/controllers/backoffice/backoffice_controller.rb
module Backoffice
  class BackofficeController < ApplicationController
    before_action :authenticate_user! # si tu utilises Devise
    def update_by_date
    @available_date = AvailableDate.find_by(date: params[:date])
    if @available_date&.update(time_slot: params[:time_slot])
      render json: { success: true }
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end

  def destroy
    @available_date = AvailableDate.find_by(date: params[:id]) # ← date au lieu d'id
    @available_date&.destroy
    head :no_content
  end
      # Tu peux ajouter ici :
      # - protection admin
      # - layout spécifique
      # - logique commune
  end
end
