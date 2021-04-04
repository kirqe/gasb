require 'bundler' 
Bundler.require # requires everything from Gemfile

require 'time'
require 'sidekiq/web'
require 'google-apis-analytics_v3'
require 'google-apis-analyticsdata_v1beta'
require "google/apis"
require 'rack/throttle'
require 'mock_redis'

require 'uri'
require 'net/http'
require 'openssl'

require 'figaro/sinatra'

if ENV['RACK_ENV'] == 'test'
  $redis = MockRedis.new
else
  $redis = Redis.new( url: ENV['REDIS_URL'] )
end

require_relative '../lib/descendable'
require_relative '../lib/helpers'
require_relative '../lib/middleware/blank'
require_relative '../lib/middleware/access'
require_relative '../lib/term'
require_relative '../models/subscription'
require_relative '../models/plan'
require_relative '../models/user'
require_relative '../lib/db/cache'

require_relative '../lib/db/report_repository'
require_relative '../lib/service/service'
require_relative '../lib/paddle'
require_relative '../lib/token'
require_relative '../lib/workers/ga3_status_worker.rb'
require_relative '../lib/workers/ga4_status_worker.rb'
require_relative '../lib/workers/mail_worker'

require_relative '../lib/report'
require_relative '../api'
require_relative '../web'
