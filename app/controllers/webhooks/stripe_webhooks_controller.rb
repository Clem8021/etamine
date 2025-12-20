# app/controllers/webhooks/stripe_webhooks_controller.rb
module Webhooks
  class StripeWebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token

    def receive
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      endpoint_secret = ENV["STRIPE_WEBHOOK_SECRET"]

      begin
        event = Stripe::Webhook.construct_event(
          payload,
          sig_header,
          endpoint_secret
        )
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
      order_id = session.dig("metadata", "order_id")

      unless order_id.present?
        Rails.logger.error "❌ Webhook sans order_id"
        return
      end

      order = Order.find_by(id: order_id)
      return unless order
      return if order.status == "payée"

      delivery = order.delivery_detail

      order.update_columns(
        status: "payée",
        email: order.email.presence || delivery&.recipient_email,
        full_name: order.full_name.presence || [
          delivery&.recipient_firstname,
          delivery&.recipient_name
        ].compact.join(" "),
        phone_number: order.phone_number.presence || delivery&.recipient_phone,
        updated_at: Time.current
      )

      begin
        OrderMailer.confirmation_email(order).deliver_later
        OrderMailer.shop_notification(order).deliver_later
      rescue => e
        Rails.logger.error "❌ Erreur email commande #{order.id} : #{e.message}"
      end

      Rails.logger.info "✅ Commande #{order.id} marquée payée via webhook Stripe"
    end
  end
end
