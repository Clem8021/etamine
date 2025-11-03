Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

# config/initializers/stripe.rb
if ENV["FORCE_TEST_CHECKOUT"] == "1"
  Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY_TEST")
else
  Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY")
end
