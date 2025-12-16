class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = ENV["STRIPE_WEBHOOK_SECRET"]

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      Rails.logger.error "❌ Stripe Webhook JSON Error: #{e.message}"
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "❌ Stripe Signature Error: #{e.message}"
      return head :bad_request
    end

    case event["type"]
    when "checkout.session.completed"
      handle_checkout_completed(event)
    else
      Rails.logger.info "ℹ️ Stripe Webhook ignoré: #{event['type']}"
    end

    head :ok
  end

  private

  def handle_checkout_completed(event)
    session = event["data"]["object"]
    order_id = session["metadata"]["order_id"]

    return unless order_id.present?

    Rails.logger.info "🎯 Webhook: checkout.session.completed pour order_id=#{order_id}"

    order = Order.find_by(id: order_id)

    unless order
      Rails.logger.error "❌ Webhook: Order introuvable (id=#{order_id})"
      return
    end

    # ⛔️ Protection anti-doublon
    return if order.status == "payée"

    order.update_column(:status, "payée")

    begin
      OrderMailer.confirmation_email(order).deliver_later
      OrderMailer.shop_notification(order).deliver_later
      Rails.logger.info "📧 Emails envoyés pour la commande #{order_id}"
    rescue => e
      Rails.logger.error "❌ Webhook email error: #{e.message}"
    end
  end
end
