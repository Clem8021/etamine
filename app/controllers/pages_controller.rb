class PagesController < ApplicationController
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
  def galerie
    @events = Event.active.ordered.includes(photos_attachments: :blob)
  end
end
