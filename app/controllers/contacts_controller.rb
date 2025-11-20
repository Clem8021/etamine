class ContactsController < ApplicationController
  def create
    ContactMailer.contact_email(params[:name], params[:email], params[:message]).deliver_now
    redirect_to contact_path, notice: "Votre message a été envoyé !"
  end
end
