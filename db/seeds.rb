require './config/environment'

User.create(email: "test@test.com", password: "test123")

Plan.create(
  name: "monthly", 
  price: 2.95, 
  note: "cancel anytime", 
  paddle_product_id: 641005,
  per: "month",
  featured: false
)

Plan.create(
  name: "semiannually", 
  price: 11.95, 
  note: "~ $1.99 per month", 
  paddle_product_id: 641088,
  per: "six months",
  featured: false
)

Plan.create(
  name: "annualy", 
  price: 19.95, 
  note: "~ $1.66 per month", 
  paddle_product_id: 639997,
  per: "year",
  featured: true
)