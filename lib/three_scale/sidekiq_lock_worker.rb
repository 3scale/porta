# frozen_string_literal: true

module ThreeScale
  # We don't actually need this in production. However, in the tests sidekiq-lock's `#lock` returns always `nil` due to
  # Sidekiq::Middleware not being active in this environment and so the thread instance variable that holds the lock is
  # never set. With effect, the tests fail with `undefined method acquire! for nil:NilClass` even though the
  # implementation is correct.
  #
  # Sidekiq::Middleware could be activated or sidekiq-lock test helpers used instead, but since we have so many
  # different types of tests, it would be either tedious to make it work to all of them or we could end up not testing
  # the actual implementation.
  module SidekiqLockWorker
    def self.included(base)
      base.send(:define_method, ::Sidekiq.lock_method) do |*args|
        Thread.current[::Sidekiq::Lock::THREAD_KEY] ||= begin
          options = self.class.get_sidekiq_options['lock']
          ::Sidekiq::Lock::RedisLock.new(options, args)
        end
      end
    end
  end
end
