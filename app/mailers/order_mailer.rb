class OrderMailer < ApplicationMailer
  default from: "contact@letamine.fr", reply_to: "contact@letamine.fr"

  layout "mailer_shop", only: [:shop_notification]

  # 🧾 Mail de confirmation pour le client
  def confirmation_email(order)
    @order = order
    @user = @order.user
    @delivery = @order.delivery_detail

    recipient =
      @order.email.presence ||
      @delivery&.recipient_email.presence ||
      @user&.email.presence

    unless recipient.present?
      Rails.logger.error("❌ Aucun email client pour la commande #{@order.id}")
      return
    end

    mail(
      to: recipient,
      subject: "🌸 Confirmation de votre commande sur L'Étamine"
    )
  end

  # 🪻 Mail interne pour la boutique
  def shop_notification(order)
    @order = order
    @user = @order.user
    @delivery = @order.delivery_detail

    mail(
      to: ENV.fetch("SHOP_NOTIFICATION_EMAIL", "contact@letamine.fr"),
      subject: "🧺 Nouvelle commande ##{@order.id} – Préparation"
    )
  end
end
