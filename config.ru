require './config/environment'

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['redis_url'] }
  config.average_scheduled_poll_interval = 5 # reduce worker delay
end
Sidekiq.default_worker_options['retry'] = false

map "/kiq" do
  Sidekiq::Web.set :sessions, false
  use Rack::Auth::Basic, "Protected Area" do |username, password|
    Rack::Utils.secure_compare(
      ::Digest::SHA256.hexdigest(username), 
      ::Digest::SHA256.hexdigest(ENV['sidekiq_un'])
    ) &
    Rack::Utils.secure_compare(
      ::Digest::SHA256.hexdigest(password), 
      ::Digest::SHA256.hexdigest(ENV['sidekiq_ps'])
    )
  end

  run Sidekiq::Web
end

use Rack::Session::EncryptedCookie, 
  :key => 'rack.session',
  :expire_after => 50000,
  :secret => ENV['rack_secret']
  
# use Rack::Throttle::Rules, 
# rules: [
#   { method: "GET", path: "/api/status/.*", limit: 30 },
#   { method: "GET", path: "/sidekiq/.*", whitelisted: true},
# ], ip_whitelist: [
#   "0.0.0.0"
# ], default: 1

run Rack::URLMap.new({
  '/' => Web,
  '/api' => Api
})
