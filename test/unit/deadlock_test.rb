require 'test_helper'

class DeadlockTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  class Model < ActiveRecord::Base
    self.table_name = 'accounts'

    def self.find(*)
      raise ActiveRecord::StatementInvalid, "MySQL::Error: Deadlock found when trying to get lock"
    end
  end

  def test_transaction_is_retried
    check = stub
    check.expects(:call).times(4)

    assert_raise ActiveRecord::StatementInvalid do
      Model.transaction do
        check.call

        Model.find(1)
      end
    end
  end
end

