class StripeCheckoutCompletedJob < ApplicationJob
  queue_as :default

  def perform(event_json)
    event = JSON.parse(event_json)
    Rails.logger.info "Stripe event reçu : #{event.inspect}"

    return unless event["data"] && event["data"]["object"]
    session = event["data"]["object"]

    order_id = session.dig("metadata", "order_id")
    return unless order_id
    # order_id ||= 5430  # pour test local si nécessaire

    order = Order.find_by(id: order_id)
    return unless order
    return if order.status == "payée"

    delivery = order.delivery_detail

    order.update_columns(
      status: "payée",
      email: order.email.presence || delivery&.recipient_email,
      phone_number: order.phone_number.presence || delivery&.recipient_phone,
      full_name: order.full_name.presence || [delivery&.recipient_firstname, delivery&.recipient_name].compact.join(" ").presence || "Client"
    )

    # emails async (ou .deliver_now pour test local)
    OrderMailer.confirmation_email(order).deliver_later
    OrderMailer.shop_notification(order).deliver_later

    Rails.logger.info "Commande #{order.id} traitée via job async"
  end
end
