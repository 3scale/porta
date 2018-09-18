sidekiq: bundle exec rake sidekiq:worker
web: UNICORN_WORKERS=2 rails server -b 0.0.0.0 unicorn
apicast: $(make compose) up apicast
backend: $(make compose) up backend-listener
