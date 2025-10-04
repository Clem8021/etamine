class OrderMailer < ApplicationMailer
  default from: "contact@letamine.fr"

  # Mail pour l’admin
  def new_order_email(order)
    @order = order
    mail(
      to: "contact@letamine.fr",
      subject: "🌸 Nouvelle commande ##{order.id} - #{order.full_name}"
    )
  end

  # Mail pour le client
  def confirmation_email(order)
    @order = order
    mail(
      to: @order.email,
      subject: "🌸 Merci #{@order.full_name}, votre commande ##{order.id} est confirmée !"
    )
  end
end
