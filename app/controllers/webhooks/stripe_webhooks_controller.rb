# app/controllers/webhooks/stripe_webhooks_controller.rb
module Webhooks
  class StripeWebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token

    def receive
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      endpoint_secret = ENV["STRIPE_WEBHOOK_SECRET"]

      event = Stripe::Webhook.construct_event(
        payload,
        sig_header,
        endpoint_secret
      )

      # ✅ RÉPONSE IMMÉDIATE À STRIPE
      head :ok

      # ✅ TRAITEMENT ASYNC
      process_event(event)

    rescue JSON::ParserError => e
      Rails.logger.error "❌ Stripe Webhook JSON Error: #{e.message}"
      head :bad_request
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "❌ Stripe Signature Error: #{e.message}"
      head :bad_request
    end

    private

    def process_event(event)
      case event["type"]
      when "checkout.session.completed"
        StripeCheckoutCompletedJob.perform_later(event.to_json)
      else
        Rails.logger.info "ℹ️ Stripe Webhook ignoré: #{event['type']}"
      end
    end
  end
end
