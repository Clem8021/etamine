class StripeCheckoutCompletedJob < ApplicationJob
  queue_as :default

  def perform(session_id)
    session = Stripe::Checkout::Session.retrieve(session_id)

    order_id = session.metadata&.[]("order_id")
    unless order_id
      Rails.logger.error "❌ [StripeCheckoutCompletedJob] Session #{session_id} sans order_id dans les métadonnées"
      return
    end

    order = Order.find_by(id: order_id)
    unless order
      Rails.logger.error "❌ [StripeCheckoutCompletedJob] Commande #{order_id} introuvable en base"
      return
    end

    if order.status == "payée"
      Rails.logger.info "⚠️ [StripeCheckoutCompletedJob] Commande #{order_id} déjà payée, skip"
      return
    end

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

    Rails.logger.info "✅ [StripeCheckoutCompletedJob] Commande #{order.id} traitée via session #{session_id}"

  rescue Stripe::StripeError => e
    Rails.logger.error "❌ [StripeCheckoutCompletedJob] Stripe API error: #{e.class} - #{e.message}"
    raise
  rescue => e
    Rails.logger.error "❌ [StripeCheckoutCompletedJob] Erreur: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end
end
