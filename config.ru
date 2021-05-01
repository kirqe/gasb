require './config/environment'

use Rack::Session::EncryptedCookie, 
:key => 'rack.session',
:expire_after => 50000,
:secret => ENV['RACK_SECRET']

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] }
  config.average_scheduled_poll_interval = 5 # reduce worker delay
end

Sidekiq.default_worker_options['retry'] = false

map "/kiq" do
  use Rack::Auth::Basic, "Protected Area" do |username, password|
    Rack::Utils.secure_compare(
      ::Digest::SHA256.hexdigest(username), 
      ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_UN'])
    ) &
    Rack::Utils.secure_compare(
      ::Digest::SHA256.hexdigest(password), 
      ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_PS'])
    )
  end

  run Sidekiq::Web
end

# use Rack::Throttle::Rules, 
# rules: [
#   { method: "GET", path: "/api/status/.*", limit: 30 },
#   { method: "GET", path: "/sidekiq/.*", whitelisted: true},
# ], ip_whitelist: [
#   "0.0.0.0"
# ], default: 1

run Rack::URLMap.new({
  '/' => Web,
  '/api/v1' => Api
})
