class MariageController < ApplicationController
  before_action :authenticate_client!, only: [:wedding_design]

  def wedding_design
    # ici tu peux mettre des variables pour la vue si besoin
  end

    def fleuriste
    # variables spécifiques à la page fleuriste
  end

  private

  def authenticate_client!
    authenticate_or_request_with_http_basic("Espace privé") do |username, password|
      username == ENV["PREVIEW_USER"] && password == ENV["PREVIEW_PASSWORD"]
    end
  end
end
