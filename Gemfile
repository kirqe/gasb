source "https://rubygems.org"

gem 'puma'
gem "sinatra"
gem "google-api-client", "~> 0.34"
gem "sidekiq"
gem "redis"
gem "require_all"
gem "rack-throttle"
gem 'slim'
gem 'bcrypt'
gem 'encrypted_cookie'
gem 'pg'
gem 'rake'
gem 'activerecord', :require => "active_record"
gem 'sinatra-activerecord'
gem 'jwt'
gem 'php_serialize' # used for paddle pub key
gem 'pony'

# https://github.com/laserlemon/figaro/pull/229
gem 'figaro', :git => 'https://github.com/bpaquet/figaro.git', :branch => 'sinatra'

group :development, :test do
  gem 'rack-test'
  gem 'rspec'
  gem 'mock_redis'
  gem 'database_cleaner'
end