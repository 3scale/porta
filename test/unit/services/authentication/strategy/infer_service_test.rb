# frozen_string_literal: true

require 'test_helper'

class Authentication::Strategy::InferServiceTest < ActiveSupport::TestCase

  setup do
    @provider = FactoryBot.create(:simple_provider)
  end

  class AdminPortalTest < Authentication::Strategy::InferServiceTest
    setup do
      @admin_domain = true
    end

    class TokenTest < AdminPortalTest
      test 'it infers the :token strategy from parameters' do
        params = { token: 'foo', expires_at: Time.zone.now + 1.minute }

        strategy = Authentication::Strategy::InferService.call(params, @provider, admin_domain: @admin_domain).result

        assert strategy.is_a? Authentication::Strategy::Token
      end

      test 'it infers the :token strategy from parameters when sso is enforced' do
        @provider.settings.expects(:enforce_sso?).returns(true)
        params = { token: 'foo', expires_at: Time.zone.now + 1.minute }

        strategy = Authentication::Strategy::InferService.call(params, @provider, admin_domain: @admin_domain).result

        assert strategy.is_a? Authentication::Strategy::Token
      end
    end

    class ProviderOauth2Test < AdminPortalTest
      test 'it infers the :provider_oauth2 strategy from parameters' do
        params = { system_name: 'foo', code: 'bar' }

        strategy = Authentication::Strategy::InferService.call(params, @provider, admin_domain: @admin_domain).result

        assert strategy.is_a? Authentication::Strategy::ProviderOAuth2
      end

      test 'it infers the :provider_oauth2 strategy from parameters when sso is enforced' do
        @provider.settings.expects(:enforce_sso?).returns(true)
        params = { system_name: 'foo', code: 'bar' }

        strategy = Authentication::Strategy::InferService.call(params, @provider, admin_domain: @admin_domain).result

        assert strategy.is_a? Authentication::Strategy::ProviderOAuth2
      end
    end

    class InternalTest < AdminPortalTest
      test 'it infers the :internal strategy from parameters' do
        params = { username: 'foo', password: 'bar' }

        strategy = Authentication::Strategy::InferService.call(params, @provider, admin_domain: @admin_domain).result

        assert strategy.is_a? Authentication::Strategy::Internal
      end

      test 'it infers the :provider_oauth2 strategy from parameters when sso is enforced' do
        @provider.settings.expects(:enforce_sso?).returns(true)
        params = { username: 'foo', password: 'bar' }

        strategy = Authentication::Strategy::InferService.call(params, @provider, admin_domain: @admin_domain).result

        assert strategy.is_a? Authentication::Strategy::ProviderOAuth2
      end
    end
  end

  class DeveloperPortalTest < Authentication::Strategy::InferServiceTest
    setup do
      @admin_domain = false
    end

    class InternalTest < DeveloperPortalTest
      test 'it infers the :internal strategy from parameters' do
        params = { username: 'foo', password: 'bar' }

        strategy = Authentication::Strategy::InferService.call(params, @provider, admin_domain: @admin_domain).result

        assert strategy.is_a? Authentication::Strategy::Internal
      end
    end

    class Oauth2Test < DeveloperPortalTest
      test 'it infers the :oauth2 strategy from parameters' do
        params = { system_name: 'foo', code: 'bar' }

        strategy = Authentication::Strategy::InferService.call(params, @provider, admin_domain: @admin_domain).result

        assert strategy.is_a? Authentication::Strategy::OAuth2
      end
    end
  end

  class NullTest < Authentication::Strategy::InferServiceTest
    {nil: nil, empty: {}, invalid: { invalid: true }}.each do |name, params|
      test "it infers the :null strategy from #{name} parameters" do
        strategy = Authentication::Strategy::InferService.call(params, @provider, admin_domain: @admin_domain).result

        assert strategy.is_a? Authentication::Strategy::Null
      end
    end
  end
end
