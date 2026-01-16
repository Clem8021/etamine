# app/jobs/stripe_checkout_completed_job.rb
class StripeCheckoutCompletedJob < ApplicationJob
  queue_as :default

  def perform(event_json)
    event = JSON.parse(event_json)
    session = event["data"]["object"]
    order_id = session.dig("metadata", "order_id")
    return unless order_id

    order = Order.find_by(id: order_id)
    return unless order
    return if order.status == "payée"

    delivery = order.delivery_detail

    order.update_columns(
      status: "payée",
      email: order.email.presence || delivery&.recipient_email,
      phone_number: order.phone_number.presence || delivery&.recipient_phone,
      full_name: order.full_name.presence || [
        delivery&.recipient_firstname,
        delivery&.recipient_name
      ].compact.join(" ").presence || "Client"
    )

    OrderMailer.confirmation_email(order).deliver_later
    OrderMailer.shop_notification(order).deliver_later

    Rails.logger.info "✅ Commande #{order.id} traitée via job"
  end
end
