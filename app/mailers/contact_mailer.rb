class ContactMailer < ApplicationMailer
  default to: "contact@letamine.fr"  # 👈 adresse de réception

  def contact_email(name, email, message)
    @name = name
    @email = email
    @message = message

    mail(
      from: email,
      subject: "Nouveau message depuis le formulaire de contact"
    )
  end
end
