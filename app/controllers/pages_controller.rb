class PagesController < ApplicationController
  before_action :restrict_private_pages, only: [
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
    return if current_user&.admin?
    return if params[:key].to_s == ENV["PREVIEW_KEY"].to_s

    Rails.logger.info "🚫 BLOCK MARIAGE – HALT RENDER"
    @wedding_coming_soon = true

    render "pages/blocked", layout: "application"
  end
end
