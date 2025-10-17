class OrderMailer < ApplicationMailer
  default from: "contact@letamine.fr"

  def confirmation_email(order)
    @order = order
    @user = @order.user
    @delivery = @order.delivery_detail

    # ✅ Choix du destinataire
    recipient =
      if @user&.email.present?
        @user.email
      elsif @delivery&.respond_to?(:recipient_email) && @delivery.recipient_email.present?
        @delivery.recipient_email
      else
        "contact@letamine.fr" # fallback pour test
      end

    mail(
      to: recipient,
      subject: "🌸 Confirmation de votre commande sur L'Étamine"
    )
  end
end
