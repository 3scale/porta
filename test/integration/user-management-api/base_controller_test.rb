require 'test_helper'

class Admin::Api::BaseControllerIntegrationTest < ActionDispatch::IntegrationTest
  include ApiRouting

  def setup
    @provider = FactoryBot.create(:simple_provider)
    @user = FactoryBot.create(:simple_admin, account: @provider)
    @token = FactoryBot.create(:access_token, owner: @user, scopes: %w(account_management), permission: 'rw')

    host! @provider.admin_domain
  end

  def test_wrapped_parameters_on_multipart_form
    body = multipart
    with_api_routes do
      post '/api', body, {'Content-Type' => 'multipart/form-data; boundary=--0123456789', 'Content-Length' => body.size}
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 'Multipart request', json['name']
      assert_equal '{"hello": "world"}', json['body']
    end
  end

  def test_unknown_format
    with_api_routes do
      get '/api/version/2.php', access_token: @token.value
      assert_response :not_acceptable
    end
  end

  class TenantModeTest < ActionDispatch::IntegrationTest

    include ApiRouting
    disable_transactional_fixtures!

    def setup
      @provider = FactoryBot.create(:simple_provider)
      @user = FactoryBot.create(:simple_admin, account: @provider)
      @user.access_tokens.create!(name: 'API', scopes: %w(account_management), permission: 'ro') do |token|
        token.value = 'access_token'
      end
      ThreeScale.config.stubs(tenant_mode: 'multitenant')
    end

    def test_provider_admin_domain
      host! @provider.admin_domain
      with_api_routes do
        get '/api', access_token: 'access_token'
        assert_response :success
      end
    end

    def test_provider_domain
      host! @provider.domain
      with_api_routes do
        assert_raise(ActionController::RoutingError) do
          get '/api', access_token: 'access_token'
        end
      end
    end

    def test_master_tenant_mode_on_prem
      host! 'random.example.net'
      ThreeScale.config.stubs(tenant_mode: 'master')
      ThreeScale.config.stubs(onpremises: true)
      user = FactoryBot.create(:simple_admin, account: master_account)
      user.access_tokens.create!(name: 'API', scopes: %w(account_management), permission: 'ro') do |token|
        token.value = 'master_access_token'
      end

      with_api_routes do
        get '/api', access_token: 'master_access_token'
        assert_response :success
      end
    end

    def test_master_domain
      @user.account = master_account
      @user.save!

      with_api_routes do
        host! master_account.admin_domain
        get '/api', access_token: 'access_token'
        assert_response :success
      end
    end

    def test_random_domain
      host! 'random.example.net'

      assert_raise(ActionController::RoutingError) do
        ThreeScale.config.stubs(tenant_mode: 'multitenant')
        get '/api', access_token: 'access_token'
      end
    end
  end

  protected

  def multipart
    boundary = '----0123456789'
    parts = {body: '{"hello": "world"}', name: 'Multipart request', access_token: @token.value}
    body = parts.map do |key, val|
      %(Content-Disposition: form-data; name="#{key}"\r\n\r\n#{val}\r\n)
    end.join(boundary + "\r\n")

    "\r\n#{boundary}\r\n" + body + "#{boundary}--\r\n"
  end
end
