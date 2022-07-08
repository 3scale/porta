# frozen_string_literal: true

require 'test_helper'

class DomainSubstitutionTest < ActiveSupport::TestCase
  include ThreeScale::DomainSubstitution

  def setup
    Rails.application.config.stubs(:domain_substitution).returns(config)
  end

  protected

  def config
    @config ||= ActiveSupport::OrderedOptions.new.merge({
      enabled: true,
      request_pattern: '\.preview\.example.com',
      request_replacement: '.localhost',
      response_pattern: '\.localhost',
      response_replacement: '.foo.bar'
    })
  end

  class RequestTest < DomainSubstitutionTest

    def test_internal_host_if_disabled
      config.enabled = false
      request = ActionDispatch::TestRequest.create
      request.host = 'foo.preview.example.com'
      assert_equal 'foo.preview.example.com', request.internal_host
    end

    def test_internal_host_when_matched
      request = ActionDispatch::TestRequest.create
      request.host = 'foo.preview.example.com'
      assert_equal 'foo.localhost', request.internal_host
    end

    def test_internal_host_when_unmatched
      request = ActionDispatch::TestRequest.create
      request.host = 'foo.preview.3scale.net'
      assert_equal 'foo.preview.3scale.net', request.internal_host
    end
  end

  class AccountModuleTest < DomainSubstitutionTest
    def setup
      @account = FactoryBot.build(:simple_account,
        domain: 'foo.example.com',
        self_domain: 'foo-admin.example.com',
        provider: true
      )
    end

    def test_internal_domain
      assert_equal @account['domain'], @account.internal_domain
    end

    def test_internal_admin_domain
      assert_equal @account['self_domain'], @account.internal_admin_domain
    end

    def test_external_domain
      Substitutor.expects(:to_external).with(@account['domain'])
      @account.external_domain
    end

    def test_external_self_domain
      Substitutor.expects(:to_external).with(@account['self_domain'])
      @account.internal_admin_domain
    end

    def test_external_admin_domain
      Substitutor.expects(:to_external).with(@account['self_domain'])
      @account.external_admin_domain
    end
  end

  class SubstitutorTest < DomainSubstitutionTest

    def test_disabled
      config.enabled = false
      assert_equal 'foo.preview.example.com', Substitutor.to_internal('foo.preview.example.com')
      assert_equal 'foo.localhost', Substitutor.to_external('foo.localhost')
    end

    def test_enabled
      assert_equal 'foo.localhost', Substitutor.to_internal('foo.preview.example.com')
      assert_equal 'foo.foo.bar', Substitutor.to_external('foo.localhost')
    end
  end

  test 'external domain could be different' do
    # TODO
  end
end
