module TestHelpers
  module ActiveRecord

    # Stub :find method on +source+ object to return +returns+ when called with it's +to_param+
    # as argument.
    def stub_find(source, returns)
      fake_find(:stubs, source, returns)
    end

    def expect_find(source, returns)
      fake_find(:expects, source, returns)
    end

    # Stubs :find method on an association or named scope chain.
    #
    # == Example
    #
    #   # Will stub @company.users.active to return @dude
    #   stub_find_on_chain(@company, :users, :active, @dude)
    #
    def stub_find_on_chain(source, *args)
      returns = args.pop

      end_of_chain = stub("result of #{args.last}")
      end_of_chain.stubs(:find).with(returns.to_param).returns(returns)

      source.stub_chain(*args).returns(end_of_chain)
    end

    private

    def fake_find(method, source, returns)
      source.send(method, :find).with(returns.to_param).returns(returns)
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::ActiveRecord)
