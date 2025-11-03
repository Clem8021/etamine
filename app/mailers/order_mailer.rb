class OrderMailer < ApplicationMailer
  default from: "contact@letamine.fr"

  # 🧾 Mail de confirmation pour le client
  def confirmation_email(order)
    @order = order
    @user = @order.user
    @delivery = @order.delivery_detail

    # ✅ Choix du destinataire (client)
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

  # 🪻 Mail interne pour la boutique (notification commande)
  def shop_notification(order)
    @order = order
    @user = @order.user
    @delivery = @order.delivery_detail

    mail(
      to: ENV.fetch("SHOP_NOTIFICATION_EMAIL", "contact@letamine.fr"), # ← ta boîte de réception
      subject: "🧺 Nouvelle commande ##{order.id} – Préparation"
    )
  end
end
