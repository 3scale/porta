require 'database_cleaner'

module TestHelpers
  module TransactionalFixtures
    def disable_transactional_fixtures!

      self.use_transactional_fixtures = false

      self.teardown do
        DatabaseCleaner.clean_with :deletion
      end

      self.setup do
        DatabaseCleaner.clean_with :deletion
      end
    end
  end
end

# ActiveRecord::Base.send(:include, AfterCommit::AfterSavepoint)
# ActiveRecord::Base.include_after_savepoint_extensions

ActiveSupport::TestCase.send(:extend, TestHelpers::TransactionalFixtures)


DatabaseCleaner.clean_with(:deletion)
