require 'test_helper'

class Apicast::ProviderLuaGeneratorTest < ActiveSupport::TestCase
  def setup
    @generator = Apicast::ProviderLuaGenerator.new
  end

  def test_emit_empty
    source = Apicast::ProviderSource.new(mock('account'))

    assert @generator.emit(source).presence
  end

  def test_emit
    account = FactoryBot.create(:provider_account)
    FactoryBot.create(:service, account: account)
    source = Apicast::ProviderSource.new(account)

    account.services.update_all(backend_version: '1')
    assert lua = @generator.emit(source.reload)

    assert_match "error_auth_failed = 'Authentication failed'", lua
    assert_match "method = 'GET'", lua

    account.services.update_all(backend_version: 'oauth')
    assert lua = @generator.emit(source.reload)

    account.services.update_all(backend_version: '2')
    assert lua = @generator.emit(source.reload)
  end

  class HelpersTest < ActiveSupport::TestCase
    include Apicast::ProviderLuaGenerator::Helpers

    def test_check_querystring_params
      assert_equal %(args["bar"] == 'baz'), check_querystring_params(bar: 'baz')
      assert_equal 'args["foo"] ~= nil', check_querystring_params(foo: '${bar}')
      assert_equal %(args["bar"] == 'baz'), check_querystring_params(bar: 'baz')
      assert_equal %(args["foo"] ~= nil and args["bar"] == 'baz'), check_querystring_params(foo: '${bar}', bar: 'baz')
    end

  end
end
