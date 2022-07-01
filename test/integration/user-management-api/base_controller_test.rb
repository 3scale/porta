# frozen_string_literal: true

require 'test_helper'

class Admin::Api::BaseControllerIntegrationTest < ActionDispatch::IntegrationTest
  include ApiRouting

  def setup
    @provider = FactoryBot.create(:simple_provider)
    @user = FactoryBot.create(:simple_admin, account: @provider)
    @token = FactoryBot.create(:access_token, owner: @user, scopes: %w[account_management], permission: 'rw')

    host! @provider.internal_admin_domain
  end

  def test_wrapped_parameters_on_multipart_form
    body = multipart
    with_api_routes do
      post '/api', params: body, headers: {'Content-Type' => 'multipart/form-data; boundary=--0123456789', 'Content-Length' => body.size}
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 'Multipart request', json['name']
      assert_equal '{"hello": "world"}', json['body']
    end
  end

  def test_unknown_format
    with_api_routes do
      get '/api/version/2.php', params: {access_token: @token.value}
      assert_response :not_acceptable
    end
  end

  class RepresentedPaginationMetadataTest < ActionDispatch::IntegrationTest
    include RepresentedApiRouting
    disable_transactional_fixtures!

    def setup
      provider = FactoryBot.create(:provider_account)
      @token = FactoryBot.create(:access_token, owner: provider.admin_users.first!, scopes: %w[account_management]).value
      host! provider.internal_admin_domain
    end

    test 'JSON for a representer class without pagination' do
      with_api_routes do
        get '/api/klas', params: { format: :json, words: %w[hello world example], access_token: @token }
        assert_nil JSON.parse(response.body)['metadata']
      end
    end

    test 'JSON pagination metadata for a representer class' do
      with_api_routes do
        get '/api/klas', params: { format: :json, words: %w[hello world example], per_page: 1, page: 2, access_token: @token }
        response_hash = JSON.parse(response.body)
        assert_equal 1, response_hash.dig('metadata', 'per_page')
        assert_equal 3, response_hash.dig('metadata', 'total_entries')
        assert_equal 3, response_hash.dig('metadata', 'total_pages')
        assert_equal 2, response_hash.dig('metadata', 'current_page')
      end
    end

    test 'JSON for a representer module without pagination' do
      with_api_routes do
        get '/api/mods', params: { format: :json, words: %w[hello world example], access_token: @token }
        assert_nil JSON.parse(response.body)['metadata']
      end
    end

    test 'JSON pagination metadata for a representer module' do
      with_api_routes do
        get '/api/mods', params: { format: :json, words: %w[hello world example], per_page: 1, page: 2, access_token: @token }
        response_hash = JSON.parse(response.body)
        assert_equal 1, response_hash.dig('metadata', 'per_page')
        assert_equal 3, response_hash.dig('metadata', 'total_entries')
        assert_equal 3, response_hash.dig('metadata', 'total_pages')
        assert_equal 2, response_hash.dig('metadata', 'current_page')
      end
    end

    test 'XML for a representer class without pagination' do
      with_api_routes do
        get '/api/klas', params: { format: :xml, words: %w[hello world example], access_token: @token }
        response_hash = Hash.from_xml(response.body)
        assert_nil response_hash.dig('klass', 'per_page')
        assert_nil response_hash.dig('klass', 'total_entries')
        assert_nil response_hash.dig('klass', 'total_pages')
        assert_nil response_hash.dig('klass', 'current_page')
      end
    end

    test 'XML pagination metadata (attributes) for a representer class' do
      with_api_routes do
        get '/api/klas', params: { format: :xml, words: %w[hello world example], per_page: 1, page: 2, access_token: @token }
        response_hash = Hash.from_xml(response.body)
        assert_equal '1', response_hash.dig('klass', 'per_page')
        assert_equal '3', response_hash.dig('klass', 'total_entries')
        assert_equal '3', response_hash.dig('klass', 'total_pages')
        assert_equal '2', response_hash.dig('klass', 'current_page')
      end
    end

    test 'XML for a representer module without pagination' do
      with_api_routes do
        get '/api/mods', params: { format: :xml, words: %w[hello world example], access_token: @token }
        response_hash = Hash.from_xml(response.body)
        assert_nil response_hash.dig('mods', 'per_page')
        assert_nil response_hash.dig('mods', 'total_entries')
        assert_nil response_hash.dig('mods', 'total_pages')
        assert_nil response_hash.dig('mods', 'current_page')
      end
    end

    test 'XML pagination metadata (attributes) for a representer module' do
      with_api_routes do
        get '/api/mods', params: { format: :xml, words: %w[hello world example], per_page: 1, page: 2, access_token: @token }
        response_hash = Hash.from_xml(response.body)
        assert_equal '1', response_hash.dig('mods', 'per_page')
        assert_equal '3', response_hash.dig('mods', 'total_entries')
        assert_equal '3', response_hash.dig('mods', 'total_pages')
        assert_equal '2', response_hash.dig('mods', 'current_page')
      end
    end
  end

  class TenantModeTest < ActionDispatch::IntegrationTest

    include ApiRouting
    disable_transactional_fixtures!

    def setup
      @provider = FactoryBot.create(:simple_provider)
      @user = FactoryBot.create(:simple_admin, account: @provider)
      @user.access_tokens.create!(name: 'API', scopes: %w[account_management], permission: 'ro') do |token|
        token.value = 'access_token'
      end
      ThreeScale.config.stubs(tenant_mode: 'multitenant')
    end

    def test_provider_admin_domain
      host! @provider.internal_admin_domain
      with_api_routes do
        get '/api', params: {access_token: 'access_token'}
        assert_response :success
      end
    end

    def test_provider_domain
      host! @provider.internal_domain
      with_api_routes do
        assert_raise(ActionController::RoutingError) do
          get '/api', params: {access_token: 'access_token'}
        end
      end
    end

    def test_master_tenant_mode_on_prem
      host! 'random.example.net'
      ThreeScale.config.stubs(tenant_mode: 'master')
      ThreeScale.config.stubs(onpremises: true)
      user = FactoryBot.create(:simple_admin, account: master_account)
      user.access_tokens.create!(name: 'API', scopes: %w[account_management], permission: 'ro') do |token|
        token.value = 'master_access_token'
      end

      with_api_routes do
        get '/api', params: {access_token: 'master_access_token'}
        assert_response :success
      end
    end

    def test_master_domain
      @user.account = master_account
      @user.save!

      with_api_routes do
        host! master_account.internal_admin_domain
        get '/api', params: {access_token: 'access_token'}
        assert_response :success
      end
    end

    def test_random_domain
      host! 'random.example.net'

      assert_raise(ActionController::RoutingError) do
        ThreeScale.config.stubs(tenant_mode: 'multitenant')
        get '/api', params: {access_token: 'access_token'}
      end
    end
  end

  protected

  def multipart
    boundary = '----0123456789'
    parts = {body: '{"hello": "world"}', name: 'Multipart request', access_token: @token.value}
    body = parts.map do |key, val|
      %(Content-Disposition: form-data; name="#{key}"\r\n\r\n#{val}\r\n)
    end.join("#{boundary}\r\n")

    "\r\n#{boundary}\r\n" + body + "#{boundary}--\r\n"
  end
end
