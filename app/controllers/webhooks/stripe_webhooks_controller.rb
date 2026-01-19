# app/controllers/webhooks/stripe_webhooks_controller.rb
module Webhooks
  class StripeWebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token

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

      process_event(event)

      # ✅ Stripe DOIT recevoir 200 seulement si tout va bien
      head :ok

    rescue JSON::ParserError => e
      Rails.logger.error "❌ Stripe Webhook JSON Error: #{e.message}"
      head :bad_request

    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "❌ Stripe Signature Error: #{e.message}"
      head :bad_request

    rescue => e
      Rails.logger.error "🔥 Stripe Webhook Fatal Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      head :internal_server_error
    end

    private

    def process_event(event)
      case event.type
      when "checkout.session.completed"
        # ✅ On passe l'ID Stripe, pas du JSON
        StripeCheckoutCompletedJob.perform_later(event.data.object.id)
      else
        Rails.logger.info "ℹ️ Stripe Webhook ignoré: #{event.type}"
      end
    end
  end
end


    private

    def process_event(event)
      case event.type
      when "checkout.session.completed"
        # ✅ On passe l'ID Stripe, pas du JSON
        StripeCheckoutCompletedJob.perform_later(event.data.object.id)
      else
        Rails.logger.info "ℹ️ Stripe Webhook ignoré: #{event.type}"
      end
    end
  end
end
