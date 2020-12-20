require 'bundler' 
Bundler.require # requires everything from Gemfile

require 'time'
require 'sidekiq/web'
require 'google/apis/analytics_v3'
require 'rack/throttle'
require 'mock_redis'

if ENV['RACK_ENV'] == 'test'
  $redis = MockRedis.new
else
  $redis = Redis.new( url: ENV['REDIS_URL'] )
end

require_relative '../lib/helpers'
require_relative '../lib/db/cache'
require_relative '../lib/db/cache_report_parser'
require_relative '../lib/db/report_repository'
require_relative '../lib/account'
require_relative '../lib/service'
require_relative '../lib/workers/request_worker'

require_relative '../lib/report'
require_relative '../app'


