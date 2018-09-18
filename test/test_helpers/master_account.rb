module TestHelpers
  module MasterAccount
    def self.included(base)
      base.teardown :setup_master_account
    end

    private

    def setup_master_account
      # Oh lord would you buy me a Mercedes Benz
      $master_account_stubbed = false
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::MasterAccount)
