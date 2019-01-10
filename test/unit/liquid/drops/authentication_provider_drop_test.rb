require 'test_helper'

class Liquid::Drops::AuthenticationProviderDropTest < ActiveSupport::TestCase
  include Liquid

  setup do
    @authentication_provider = FactoryBot.build_stubbed(:authentication_provider)

    @drop = Drops::AuthenticationProvider.new(@authentication_provider)

    @drop.context = context = Liquid::Context.new
    context.registers.merge!(request: @request = stub('request', scheme: 'https', query_parameters: {}))
  end

  test '#name' do
    assert_equal @authentication_provider.name, @drop.name
  end

  test '#system_name' do
    assert_equal @authentication_provider.system_name, @drop.system_name
  end

  test '#client_id' do
    assert_equal @authentication_provider.client_id, @drop.client_id

    @authentication_provider = @authentication_provider.becomes(AuthenticationProvider::GitHub)
    @authentication_provider.brand_as_threescale(false)

    @drop = Drops::AuthenticationProvider.new(@authentication_provider)

    assert_equal 'fake_id', @drop.client_id
  end

  test '#authorize_url' do
    domain = @authentication_provider.account.domain

    authorize_url = @drop.authorize_url

    uri = URI.parse(authorize_url)
    params = Rack::Utils.parse_nested_query(uri.query)

    assert_equal "https://#{domain}/auth/#{@authentication_provider.system_name}/callback", params.fetch('redirect_uri')
  end

  test '#callback_url for master' do
    presenter = mock('oauth')
    OauthFlowPresenter.expects(:new).with(@authentication_provider, @request).returns(presenter)

    presenter.expects(:callback_url).with().once.returns('https://foo')

    assert_equal 'https://foo', @drop.callback_url
  end

  test '#callback_url' do
    domain = @authentication_provider.account.domain

    callback_url = @drop.callback_url
    assert_equal "https://#{domain}/auth/#{@authentication_provider.system_name}/callback", callback_url
  end

  protected
end
