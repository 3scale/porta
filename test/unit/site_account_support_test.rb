require 'test_helper'

class SiteAccountSupportTest < ActiveSupport::TestCase

  class Params
    attr_accessor :request

    class << self
      def before_action(*args); end

      def helper_method(*args)
        public *args
      end
    end

    include SiteAccountSupport
  end

  test 'scopes provider key search by domain' do
    p1 = FactoryBot.create(:provider_account)
    p2 = FactoryBot.create(:provider_account)

    object = Params.new
    object.request = mock(host: p2.self_domain)
    object.request.expects(:params).returns({ provider_key: p2.api_key }).at_least_once

    assert_equal p2, object.site_account

    object = Params.new
    object.request = mock(host: p2.self_domain)
    object.request.expects(:params).returns({ provider_key: p1.api_key }).at_least_once

    assert_raise Backend::ProviderKeyInvalid do
      refute object.site_account
    end
  end

  test 'raises record not found' do
    assert_raises ActiveRecord::RecordNotFound do
      Params.new.domain_account
    end
  end

  test 'master on premises' do
    ThreeScale.config.stubs(onpremises: true)
    ThreeScale.config.stubs(tenant_mode: 'master')
    mock_request = mock
    mock_request.stubs(:host).returns('anything-works')
    mock_request.stubs(:params).returns(provider_key: master_account.provider_key)
    request = SiteAccountSupport::Request.new(mock_request)

    assert_equal master_account, request.find_provider
    assert_equal master_account, request.domain_account
    assert_equal master_account, request.site_account
    assert_equal master_account, request.site_account_by_domain
    assert_equal master_account, request.site_account_by_provider_key

  end
end
