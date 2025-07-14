# config/initializers/resque.rb

require "resque"

# Configure Redis connection for Resque
Resque.redis = Redis.new(
  url: ENV.fetch("REDIS_URL"),
  password: ENV["REDIS_PASSWORD"]
)
