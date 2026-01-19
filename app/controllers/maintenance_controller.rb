class MaintenanceController < ApplicationController
  skip_before_action :maintenance_mode   # sinon boucle infinie
  layout "maintenance"                    # layout dédié

  def index
    # Ici tu peux passer des variables si besoin
    @message = "Le site est temporairement indisponible pour maintenance. Merci de revenir plus tard."
  end
end
