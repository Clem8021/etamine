class StripeCheckoutCompletedJob < ApplicationJob
  queue_as :default

  def perform(checkout_session_id)
    # 1) Récupère la session Stripe
    session = Stripe::Checkout::Session.retrieve(checkout_session_id)

    # 2) Trouve la commande via metadata
    order_id = session.dig("metadata", "order_id")
    return unless order_id

    order = Order.find_by(id: order_id)
    return unless order
    return if order.status == "payée"

    delivery = order.delivery_detail

    order.update!(
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

    Rails.logger.info "✅ Commande #{order.id} traitée via job async (session: #{checkout_session_id})"
  rescue Stripe::StripeError => e
    Rails.logger.error "❌ Stripe error: #{e.class} - #{e.message}"
    raise # important: retry automatique
  rescue => e
    Rails.logger.error "❌ Webhook job error: #{e.class} - #{e.message}"
    raise
  end
end
