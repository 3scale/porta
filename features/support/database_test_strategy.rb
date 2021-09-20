module ThreeScale
  class DatabaseTestStrategy < ::Cucumber::Rails::Database::Strategy

    class << self
      attr_accessor :current_mode
    end

    # workaround of default cucumber-rails @javascript hooks
    # hooks: https://github.com/cucumber/cucumber-rails/blob/main/lib/cucumber/rails/hooks/active_record.rb
    # background: https://github.com/cucumber/cucumber-rails/issues/166
    # upstream issue: https://github.com/cucumber/cucumber-rails/issues/521
    alias set_strategy before_js
    def before_js
      public_send self.class.current_mode if self.class.current_mode
    end
    alias before_non_js before_js

    def shared_transaction
      shared_connection!
      set_strategy :transaction
    end

    def non_shared_transaction
      non_shared_connection!
      set_strategy :transaction
    end

    def truncation
      non_shared_connection!
      set_strategy :truncation
    end

    private

    def shared_connection!
      shared_strategy.before_js
    end

    def non_shared_connection!
      shared_strategy.before_non_js
    end

    def shared_strategy
      @shared_strategy ||= ::Cucumber::Rails::Database::SharedConnectionStrategy.new
    end
  end
end
