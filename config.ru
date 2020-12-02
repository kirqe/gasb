require './config/environment'

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] }
  config.average_scheduled_poll_interval = 2 # reduce worker delay
end

use Rack::Throttle::Rules, 
rules: [
  { method: "GET", path: "/status/.*", limit: 12 },
  { method: "GET", path: "/services", limit: 3 },
  { method: "GET", path: "/sidekiq/.*", whitelisted: true},
], ip_whitelist: [
  "0.0.0.0"
], default: 1


run Rack::URLMap.new('/' => App, '/sidekiq' => Sidekiq::Web)