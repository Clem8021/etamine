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
  class OrderMailer < ApplicationMailer
    default from: "contact@letamine.fr"

    def confirmation_email(order)
      @order = order
      recipient = @order.user&.email || @order.delivery_detail&.recipient_email || "contact@letamine.fr"

      mail(
        to: recipient,
        subject: "🌸 Confirmation de votre commande sur L'Étamine"
      )
    end
  end
end
