require 'stream_rails'

StreamRails.configure do |config|
  config.api_key      = "rsmzjtaqy65g"
  config.api_secret   = "9nkk9q2wnwvjbtuv6dqkfnew683hrtchkab2rfm84p4k5kmcu7r9jfbxzgkxzd6j"
  config.timeout      = 30                  # Optional, defaults to 3
  config.location     = 'us-east'           # Optional, defaults to 'us-east'
  # If you use custom feed names, e.g.: timeline_flat, timeline_aggregated,
  # use this, otherwise omit:
  config.news_feeds = { flat: "user", aggregated: "timeline_aggregated" }
  # Point to the notifications feed group providing the name, omit if you don't
  # have a notifications feed
  config.notification_feed = "notification"
end
