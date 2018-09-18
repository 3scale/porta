module TestHelpers
  module User
    def self.included(base)
      base.teardown(:teardown_user)
    end

    def teardown_user
      ::User.current = nil
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::User)
