require 'bundler' 
Bundler.require # requires everything from Gemfile

require 'time'
require 'sidekiq/web'
require 'google/apis/analytics_v3'
require 'rack/throttle'
require 'mock_redis'

# $redis = MockRedis.new

$redis = Redis.new( url: ENV['REDIS_URL'] )

require_relative '../lib/db/cache'
require_relative '../lib/db/cache_report_parser'
require_relative '../lib/db/report_repository'
require_relative '../lib/services/service_accounts'
require_relative '../lib/services/service_registry'
require_relative '../lib/services/service'
require_relative '../lib/workers/request_worker'

require_relative '../lib/report'
require_relative '../app'


