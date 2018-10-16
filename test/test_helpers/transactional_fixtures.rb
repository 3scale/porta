require 'database_cleaner'

module TestHelpers
  module TransactionalFixtures
    extend ActiveSupport::Concern

    included do
      class_attribute :database_cleaner_strategy
      class_attribute :database_cleaner_clean_with_strategy
      self.database_cleaner_clean_with_strategy = self.database_cleaner_strategy = DatabaseCleaner::NullStrategy
    end

    class_methods do
      def disable_transactional_fixtures!
        self.use_transactional_fixtures = false
        self.database_cleaner_strategy = :truncation
        self.database_cleaner_clean_with_strategy = :truncation
      end
    end

    def before_setup
      case database_cleaner_clean_with_strategy
      when Class
        database_cleaner_clean_with_strategy.clean
      when Symbol
        DatabaseCleaner.clean_with(database_cleaner_clean_with_strategy)
      end

      DatabaseCleaner.strategy = database_cleaner_strategy
      DatabaseCleaner.start
      super
    end

    def after_teardown
      super
      DatabaseCleaner.clean
    end
  end
end

# ActiveRecord::Base.send(:include, AfterCommit::AfterSavepoint)
# ActiveRecord::Base.include_after_savepoint_extensions

ActiveSupport::TestCase.send(:include, TestHelpers::TransactionalFixtures)

DatabaseCleaner.clean_with(:deletion)
