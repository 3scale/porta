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
        proxy.service.update(backend_version: '2')
        proxy.reload
        assert_match %r(http://APP_ID:APP_KEY@), command.to_s
      end

      test 'auth mode app_id and app_key' do
        create_proxy_config
        proxy.service.update(backend_version: '2')
        assert_match(/&?app_key=APP_KEY/, command.to_s)
        assert_match(/&?app_id=APP_ID/, command.to_s)
      end

      test 'app_id and app_key with customized params name' do
        create_proxy_config(proxy: { auth_app_id: 'id', auth_app_key: 'p-a-s-s' })
        proxy.service.update(backend_version: '2')
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
        @command ||= CurlCommandBuilder.new(proxy)
      end
    end

    class UseApiTestPathOrProxyRules < self
      include ConfigBasedCommandTestHelpers

      def setup
        super

        proxy.update(api_test_path: '/test')
        FactoryBot.create(:proxy_rule, proxy: proxy, pattern: '/foo', position: 1)
        create_proxy_config(proxy: { api_test_path: '/test', proxy_rules: [{ pattern: '/foo' }] })
      end

      test 'use proxy rules based on the latest proxy config' do
        command = CurlCommandBuilder.new(proxy)
        assert_match(/\/foo\?/, command.to_s)
      end
    end
  end
end
