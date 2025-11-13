class PagesController < ApplicationController
  before_action :restrict_private_pages, only: [
    :mariage_fleuriste,
    :mariage_wedding,
    :galerie
  ]

  def home; end
  def about; end
  def contact; end
  def cgv; end

  def mariage_fleuriste; end
  def mariage_wedding; end
  def galerie; end

  private

  def restrict_private_pages
    # Admin : accès ok
    return if current_user&.admin?

    # Accès via lien privé ?key=PREVIEW_KEY
    if params[:key].to_s.strip == ENV["PREVIEW_KEY"].to_s.strip
      return
    end

    # Sinon on bloque
    redirect_to root_path, notice: "🌸 Cette page n'est pas encore disponible."
  end
end
