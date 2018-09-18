require 'test_helper'

# Dummy strategy class.
module Authentication
  module Strategy
    class FooBar < Base; end
  end
end

class Authentication::Strategy::BaseTest < ActiveSupport::TestCase
  def setup
    account = Factory(:provider_account)
    @strategy = Authentication::Strategy::FooBar.new(account)
  end

  test 'name' do
    assert_equal 'foo_bar', @strategy.name
  end

  test 'template' do
    assert_equal 'sessions/strategies/foo_bar', @strategy.template
  end

  test '#track_signup_options' do
    assert_equal({strategy: 'other'}, @strategy.track_signup_options)
  end
end
