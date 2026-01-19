module Webhooks
  class StripeWebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token

    def receive
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      endpoint_secret = ENV.fetch("STRIPE_WEBHOOK_SECRET")

      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)

      case event.type
      when "checkout.session.completed"
        StripeCheckoutCompletedJob.perform_later(event.data.object.id)
      else
        Rails.logger.info "ℹ️ Stripe webhook ignoré: #{event.type}"
      end

      head :ok
    rescue JSON::ParserError => e
      Rails.logger.error "❌ Stripe Webhook JSON Error: #{e.message}"
      head :bad_request
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "❌ Stripe Signature Error: #{e.message}"
      head :bad_request
    rescue => e
      Rails.logger.error "🔥 Stripe Webhook Fatal Error: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      head :internal_server_error
    end
  end
end
