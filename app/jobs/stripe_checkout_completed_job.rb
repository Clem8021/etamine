class StripeCheckoutCompletedJob < ApplicationJob
  queue_as :default

  def perform(session_id)
    session = Stripe::Checkout::Session.retrieve(session_id)

    order_id = session.metadata&.[]("order_id")
    return unless order_id

    order = Order.find_by(id: order_id)
    return unless order
    return if order.status == "payée"

    delivery = order.delivery_detail

    order.update!(
      status: "payée",
      email: order.email.presence || delivery&.recipient_email || session.customer_details&.email,
      phone_number: order.phone_number.presence || delivery&.recipient_phone || session.customer_details&.phone,
      full_name: order.full_name.presence || session.customer_details&.name ||
                 [delivery&.recipient_firstname, delivery&.recipient_name].compact.join(" ").presence ||
                 "Client"
    )

    OrderMailer.confirmation_email(order).deliver_later
    OrderMailer.shop_notification(order).deliver_later

    Rails.logger.info "✅ Commande #{order.id} traitée via Stripe session #{session_id}"
  rescue Stripe::StripeError => e
    Rails.logger.error "❌ Stripe API error: #{e.class} - #{e.message}"
  rescue => e
    Rails.logger.error "❌ Webhook job error: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end
