require './config/environment'

user = User.create(email: ENV['BASE_EMAIL'], password: ENV['BASE_PASSWORD'])

Plan.find_or_create_by(
  name: "monthly", 
  price: 2.95, 
  note: "cancel anytime", 
  paddle_product_id: 641005,
  per: "month",
  featured: false
)

Plan.find_or_create_by(
  name: "semiannually", 
  price: 11.95, 
  note: "~ $1.99 per month", 
  paddle_product_id: 641088,
  per: "six months",
  featured: false
)

plan = Plan.find_or_create_by(
  name: "annualy", 
  price: 19.95, 
  note: "~ $1.66 per month", 
  paddle_product_id: 639997,
  per: "year",
  featured: true
)

Subscription.find_or_create_by(plan: plan, user: user, refresh_token: "yay", expires_at: Time.now + 60 * 60 * 24 * 365 * 10)
