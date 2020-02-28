# frozen_string_literal: true

require 'test_helper'

module Apicast
  class CurlCommandBuilderTest < ActiveSupport::TestCase
    def setup
      @proxy = FactoryBot.create(:proxy,
        auth_app_key: 'app_key',
        auth_app_id: 'app_id',
        auth_user_key: 'user_key',
        credentials_location: 'query',
        api_test_path: '/test'
      )
    end

    attr_reader :proxy

    class BasedOnValuesOfModel < self
      test 'auth in query' do
        proxy.update_attributes(credentials_location: 'query')
        assert_match(/user_key=USER_KEY/, command.to_s)
      end

      test 'auth in headers' do
        proxy.update_attributes(credentials_location: 'headers')
        assert_match(/-H'user_key: USER_KEY/, command.to_s)
      end

      test 'auth basic (without password)' do
        proxy.update_attributes(credentials_location: 'authorization')
        assert_match %r(http://USER_KEY@), command.to_s
      end

      test 'auth basic (with password)' do
        proxy.update_attributes(credentials_location: 'authorization')
        proxy.service.update_attributes(backend_version: '2')
        proxy.reload
        assert_match %r(http://APP_ID:APP_KEY@), command.to_s
      end

      test 'auth mode app_id and app_key' do
        proxy.service.update_attributes(backend_version: '2')
        proxy.update_attributes(credentials_location: 'query')
        assert_match(/&?app_key=APP_KEY/, command.to_s)
        assert_match(/&?app_id=APP_ID/, command.to_s)
      end

      test 'app_id and app_key with customized params name' do
        proxy.service.update_attributes(backend_version: '2')
        proxy.update_attributes(auth_app_id: 'id')
        proxy.update_attributes(auth_app_key: 'p-a-s-s')
        assert_match(/id=APP_ID/, command.to_s)
        assert_match(/p-a-s-s=APP_KEY/, command.to_s)
      end

      test 'root path' do
        FactoryBot.create(:proxy_rule, proxy: proxy, pattern: '/', position: 1)
        assert_match(/\?user/, command.to_s)
      end

      test 'path with wildcards' do
        FactoryBot.create(:proxy_rule, proxy: proxy, pattern: '/{param}/path', position: 1)
        assert_match(%r(/{param}/path), command.to_s)
      end

      test 'path with query string' do
        FactoryBot.create(:proxy_rule, proxy: proxy, pattern: '/path?test=true', position: 1)
        assert_match(%r(/path\?test=true), command.to_s)
      end

      test 'no double ?' do
        FactoryBot.create(:proxy_rule, proxy: proxy, pattern: '/a?b=c', position: 1)
        assert_match(/a\?b=c&/, command.to_s)
      end

      test 'blank endpoint' do
        proxy.update_attributes(endpoint: '', sandbox_endpoint: '')
        refute command.command
      end

      protected

      def command
        @command ||= CurlCommandBuilder.new(proxy, build_from_config: false, use_api_test_path: false)
      end
    end

    class BasedOnLatestProxyConfig < self
      include ConfigBasedCommandTestHelpers

      test 'auth in query' do
        create_proxy_config
        assert_match(/user_key=USER_KEY/, command.to_s)
      end

      test 'auth in headers' do
        create_proxy_config(proxy: { credentials_location: 'headers' })
        assert_match(/-H'user_key: USER_KEY/, command.to_s)
      end

      test 'auth basic (without password)' do
        create_proxy_config(proxy: { credentials_location: 'authorization' })
        assert_match %r(http://USER_KEY@), command.to_s
      end

      test 'auth based (with password)' do
        create_proxy_config(proxy: { credentials_location: 'authorization' })
        proxy.service.update_attributes(backend_version: '2')
        proxy.reload
        assert_match %r(http://APP_ID:APP_KEY@), command.to_s
      end

      test 'auth mode app_id and app_key' do
        create_proxy_config
        proxy.service.update_attributes(backend_version: '2')
        assert_match(/&?app_key=APP_KEY/, command.to_s)
        assert_match(/&?app_id=APP_ID/, command.to_s)
      end

      test 'app_id and app_key with customized params name' do
        create_proxy_config(proxy: { auth_app_id: 'id', auth_app_key: 'p-a-s-s' })
        proxy.service.update_attributes(backend_version: '2')
        assert_match(/id=APP_ID/, command.to_s)
        assert_match(/p-a-s-s=APP_KEY/, command.to_s)
      end

      test 'root path' do
        create_proxy_config(proxy: { proxy_rules: [{ pattern: '/' }] })
        assert_match(/\?user/, command.to_s)
      end

      test 'path with wildcards' do
        create_proxy_config(proxy: { proxy_rules: [{ pattern: '/{param}/path' }] })
        assert_match(%r(/{param}/path), command.to_s)
      end

      test 'path with query string' do
        create_proxy_config(proxy: { proxy_rules: [{ pattern: 'path?test=true' }] })
        assert_match(%r(/path\?test=true), command.to_s)
      end

      test 'no double ?' do
        create_proxy_config(proxy: { proxy_rules: [{ pattern: '/a?b=c' }] })
        assert_match(/a\?b=c&/, command.to_s)
      end

      test 'blank endpoint' do
        create_proxy_config(proxy: { endpoint: '', sandbox_endpoint: '' })
        refute command.command
      end

      protected

      def command
        @command ||= CurlCommandBuilder.new(proxy, build_from_config: true, use_api_test_path: false)
      end
    end

    class UseApiTestPathOrProxyRules < self
      include ConfigBasedCommandTestHelpers

      def setup
        super

        proxy.update_attributes(api_test_path: '/test')
        FactoryBot.create(:proxy_rule, proxy: proxy, pattern: '/foo', position: 1)
        create_proxy_config(proxy: { api_test_path: '/test', proxy_rules: [{ pattern: '/foo' }] })
      end

      test 'use api_test_path based on the values of the model' do
        command = CurlCommandBuilder.new(proxy, build_from_config: false, use_api_test_path: true)
        assert_match(/\/test\?/, command.to_s)
      end

      test 'use proxy rules based on the values of the model' do
        command = CurlCommandBuilder.new(proxy, build_from_config: false, use_api_test_path: false)
        assert_match(/\/foo\?/, command.to_s)
      end

      test 'use api_test_path based on the latest proxy config' do
        command = CurlCommandBuilder.new(proxy, build_from_config: true, use_api_test_path: true)
        assert_match(/\/test\?/, command.to_s)
      end

      test 'use proxy rules based on the latest proxy config' do
        command = CurlCommandBuilder.new(proxy, build_from_config: true, use_api_test_path: false)
        assert_match(/\/foo\?/, command.to_s)
      end
    end

    class ApiapEnabledOrDisabled < self
      include ConfigBasedCommandTestHelpers

      def setup
        super
        create_proxy_config
      end

      test 'api as product enabled' do
        CurlCommandBuilder::StagingBuilder.expects(:new).with(instance_of(CurlCommandBuilder::ProxyFromConfig), {})
        CurlCommandBuilder.new(proxy)
      end

      test 'api as product disabled' do
        disable_apiap!
        CurlCommandBuilder::StagingBuilder.expects(:new).with(proxy, { test_path: '/test' })
        CurlCommandBuilder.new(proxy)
      end

      protected

      def disable_apiap!
        account = proxy.service.account
        account.stubs(:provider_can_use?).returns(true)
        account.expects(:provider_can_use?).with(:api_as_product).returns(false).at_least_once
      end
    end

    class StagingOrProductionEnvironment < self
      test 'staging environment' do
        proxy.update_column(:sandbox_endpoint, 'http://public-staging.fake')
        command = CurlCommandBuilder.new(proxy, environment: :staging, build_from_config: false, use_api_test_path: false)
        assert_match %r(http://public-staging.fake/\?user_key=), command.to_s
      end

      test 'production environment' do
        proxy.stubs(default_production_endpoint: 'http://public-production.fake')
        command = CurlCommandBuilder.new(proxy, environment: :production, build_from_config: false, use_api_test_path: false)
        assert_match %r(http://public-production.fake/\?user_key=), command.to_s
      end
    end
  end
end
