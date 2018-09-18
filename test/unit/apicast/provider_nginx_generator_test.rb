require 'test_helper'

class Apicast::ProviderNginxGeneratorTest < ActiveSupport::TestCase
  def setup
    @generator = Apicast::ProviderNginxGenerator.new
    # This way to generate apicast configs is deprecated.
  end

  def test_emit_empty
    provider = mock('provider')
    source = Apicast::ProviderSource.new(provider)

    subject = @generator.emit(source)

    assert_match 'events {', subject
    assert_match 'http {', subject
  end

  def test_emit_provider
    provider = FactoryGirl.create(:provider_account)
    source = Apicast::ProviderSource.new(provider)

    subject = @generator.emit(source)

    assert_match "require('nginx_#{provider.id}').access()", subject
  end

  def test_emit_user
    provider = FactoryGirl.create(:provider_account)
    user = provider.admins.first!
    source = Apicast::UserSource.new(user)

    subject = @generator.emit(source)

    assert_match "require('nginx_#{provider.id}').access()", subject
  end

  def test_emit_oauth
    provider = FactoryGirl.create(:provider_account)
    provider.services.update_all(backend_version: 'oauth')
    source = Apicast::ProviderSource.new(provider.reload)
    System::Application.config.stubs(backend_client: {host: 'apisonator.example.com'})

    subject = @generator.emit(source)

    assert_match "require('nginx_#{provider.id}').access()", subject
    assert_match 'post_action /out_of_band_oauth_authrep_action;', subject
    assert_match /proxy_set_header\s+Host "apisonator\.example\.com";/, subject
  end

  def test_service_conf
    provider_key = 'foobar'
    service = Service.new
    service.account_id = 42
    service.id = 21
    service.proxy = proxy = Proxy.new
    service.backend_version = 2
    proxy.oauth_login_url = 'http://example.com/login'

    subject = @generator.service_conf(service, provider_key)

    assert_equal '$hostname', subject.server_name
    assert_equal 80, subject.listen_port
    assert_equal 'nginx_42', subject.lua_file
    assert_equal 21, subject.service_id
    assert_equal 'foobar', subject.provider_key
    assert_equal '2', subject.backend_version
    assert_equal 'http://example.com/login', subject.login_url

    proxy.endpoint = 'https://3scale.net/foobar'

    subject = @generator.service_conf(service, provider_key)

    assert_equal '3scale.net', subject.server_name
    assert_equal 443, subject.listen_port
  end

  def test_upstream_service
    service = Service.new
    service.proxy = proxy = Proxy.new
    service.id = 42
    service.name = 'APIs for everyone'
    proxy.api_backend = 'https://echo-api.3scale.net'

    subject = @generator.upstream_service(service)

    assert_equal 42, subject.id
    assert_equal 'APIs for everyone', subject.name
    assert_equal 443, subject.port
    assert_equal 'echo-api.3scale.net', subject.host
  end
end
