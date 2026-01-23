# frozen_string_literal: true

require 'test_helper'

class ThreeScale::OpenApi::UrlResolverTest < ActiveSupport::TestCase
  UrlResolver = ThreeScale::OpenApi::UrlResolver

  test 'simple url' do
    specification = { 'servers' => [{'url' => 'https://api.example.com'}] }
    resolver = UrlResolver.new(specification)
    assert_equal ['https://api.example.com'], resolver.servers
  end

  test 'url with relative path' do
    specification = { 'servers' => [{'url' => '/some/relative/path'}] }
    resolver = UrlResolver.new(specification)
    assert_equal ['/some/relative/path'], resolver.servers
  end

  test 'multiple urls' do
    specification = { 'servers' => [{'url' => 'http://api.example.com'}, {'url' => 'https://api.example.com'}] }
    resolver = UrlResolver.new(specification)
    expected_servers = %w[http://api.example.com https://api.example.com]
    assert_equal expected_servers, resolver.servers
  end

  test 'url url arbitrary variable' do
    specification = {
      'servers' => [{
        'url' => '{protocol}://api.example.com',
        'variables' => {
          'protocol' => {
            'default' => 'https'
          }
        }
      }]
    }
    resolver = UrlResolver.new(specification)
    assert_equal ['https://api.example.com'], resolver.servers
  end

  test 'url empty variable' do
    specification = {
      'servers' => [{
        'url' => 'https://api.example.com',
        'variables' => {}
      }]
    }
    resolver = UrlResolver.new(specification)
    assert_equal ['https://api.example.com'], resolver.servers
  end

  test 'url with enum variable' do
    specification = {
      'servers' => [{
        'url' => '{protocol}://api.example.com',
        'variables' => {
          'protocol' => {
            'enum' => ['http', 'https'],
            'default' => 'https'
          }
        }
      }]
    }
    resolver = UrlResolver.new(specification)
    expected_servers = %w[http://api.example.com https://api.example.com]
    assert_equal expected_servers, resolver.servers
  end

  test 'url with multiple variables' do
    json = <<~JSON
      {
        "servers": [
          {
            "url": "{protocol}://{environment}.example.com/api",
            "variables": {
              "protocol": {
                "enum": [
                  "http",
                  "https"
                ],
                "default": "https"
              },
              "environment": {
                "enum": [
                  "staging",
                  "production"
                ],
                "default": "staging"
              }
            }
          }
        ]
      }
    JSON
    resolver = UrlResolver.new(JSON.parse(json))
    expected_servers = %w[
      http://staging.example.com/api
      http://production.example.com/api
      https://staging.example.com/api
      https://production.example.com/api
    ]
    assert_equal expected_servers, resolver.servers
  end

  test 'url with variable that includes URL schema' do
    json = <<~JSON
      {
        "servers": [
          {
            "url": "{baseURL}/some/path",
            "variables": {
              "baseURL": {
                "enum": [
                  "https://echo-api.3scale.net",
                  "https://api.example.com"
                ],
                "default": "https://echo-api.3scale.net"
              }
            }
          }
        ]
      }
    JSON
    resolver = UrlResolver.new(JSON.parse(json))
    expected_servers = %w[
      https://echo-api.3scale.net/some/path
      https://api.example.com/some/path
    ]
    assert_equal expected_servers, resolver.servers
  end
end
