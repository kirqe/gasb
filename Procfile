redis: redis-server
web: REDIS_URL=redis://localhost:6379 rackup config.ru
sidekiq: bundle exec sidekiq -r ./config/environment.rb