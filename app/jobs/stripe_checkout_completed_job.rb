class StripeCheckoutCompletedJob < ApplicationJob
  queue_as :default

  def perform(event_json)
    event = JSON.parse(event_json)
    session = event.dig("data", "object")
    order_id = session.dig("metadata", "order_id")
    return unless order_id

    order = Order.find_by(id: order_id)
    return unless order
    return if order.status == "payée"

    delivery = order.delivery_detail

    order.update(
      status: "payée",
      email: order.email.presence || delivery&.recipient_email,
      phone_number: order.phone_number.presence || delivery&.recipient_phone,
      full_name: order.full_name.presence ||
                 [delivery&.recipient_firstname, delivery&.recipient_name].compact.join(" ").presence ||
                 "Client"
    )

    # Emails async
    OrderMailer.confirmation_email(order).deliver_later
    OrderMailer.shop_notification(order).deliver_later

    Rails.logger.info "Commande #{order.id} traitée via job async"
  rescue JSON::ParserError => e
    Rails.logger.error "Erreur parsing Stripe event: #{e.message}"
  rescue => e
    Rails.logger.error "Erreur lors du traitement du webhook Stripe: #{e.class} - #{e.message}"
  end
end
