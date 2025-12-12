# app/controllers/stripe_webhooks_controller.rb
class StripeWebhooksController < ApplicationController
  # Stripe envoie des requêtes sans CSRF, donc on désactive la vérif
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
    end

    head :ok
  end

  private

  # === 🎉 Quand Stripe confirme un paiement ===
  def handle_checkout_completed(event)
    session = event["data"]["object"]
    order_id = session["metadata"]["order_id"]

    Rails.logger.info "🎯 Webhook: checkout.session.completed pour order_id=#{order_id}"

    order = Order.find_by(id: order_id)

    unless order
      Rails.logger.error "❌ Webhook: Order introuvable (id=#{order_id})"
      return
    end

    # Mise à jour SANS validations
    order.update_column(:status, "payée")

    # Envoi des emails
    begin
      OrderMailer.confirmation_email(order).deliver_later
      OrderMailer.shop_notification(order).deliver_later
      Rails.logger.info "📧 Emails envoyés pour la commande #{order_id}"
    rescue => e
      Rails.logger.error "❌ Webhook email error: #{e.message}"
    end
  end
end
