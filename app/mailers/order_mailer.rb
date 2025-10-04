class OrderMailer < ApplicationMailer
  default from: "contact@letamine.fr"

  # Envoi à l'administratrice à chaque nouvelle commande
  def new_order_notification(order)
    @order = order
    mail(
      to: "letamineflesselles@yahoo.com", # 📧 adresse de la cliente
      subject: "🪻 Nouvelle commande reçue sur L'Étamine"
    )
  end
end
