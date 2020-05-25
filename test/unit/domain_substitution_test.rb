# frozen_string_literal: true

require 'test_helper'

class DomainSubstitutionTest < ActiveSupport::TestCase

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

  class SubstitutorTest < DomainSubstitutionTest
    include ThreeScale::DomainSubstitution

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
end
