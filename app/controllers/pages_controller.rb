class PagesController < ApplicationController
  before_action :wedding_coming_soon, only: [
    :mariage_fleuriste,
    :mariage_wedding,
    :galerie
  ]

  def home; end
  def about; end
  def contact; end

  def contact_submit
    ContactMailer.contact_email(
      params[:name],
      params[:email],
      params[:message]
    ).deliver_now

    redirect_to contact_path, notice: "Votre message a été envoyé !"
  end

  def cgv; end

  def mariage_fleuriste; end
  def mariage_wedding; end
  def galerie; end

  private

  def restrict_private_pages
    # Admin : accès total
    return if current_user&.admin?

    # Accès via lien privé ?key=PREVIEW_KEY
    return if params[:key].to_s.strip == ENV["PREVIEW_KEY"].to_s.strip

    # 👉 Public : on affiche la popup mariage
    @wedding_coming_soon = true
  end

  def wedding_coming_soon
    return if current_user&.admin?
    return if params[:key].to_s == ENV["PREVIEW_KEY"].to_s

    @wedding_coming_soon = true
  end
end
