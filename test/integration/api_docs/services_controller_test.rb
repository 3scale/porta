require 'test_helper'

class ApiDocs::ServicesControllerTest < ActionDispatch::IntegrationTest

  def setup
    provider = FactoryBot.create(:provider_account)
    login_provider provider
  end

  def test_verify_api_files
    Rails.application.config.three_scale.stubs(onpremises_api_docs_version: false)
    assert ApiDocs::ServicesController.verify_accessible_api_files_exist!
    Rails.application.config.three_scale.stubs(onpremises_api_docs_version: true)
    assert ApiDocs::ServicesController.verify_accessible_api_files_exist!
  end

  def test_record_not_found
    get api_docs_service_path(format: :json, id: 'example-api')
    assert_response :not_found
  end

  class ProviderAccountServicesControllerTest < ApiDocs::ServicesControllerTest
    def test_index_and_show_with_finance
      get '/api_docs/services.json'
      assert_match '/api_docs/services/billing_api.json', response.body

      get '/api_docs/services/billing_api.json'
      assert_response :success


      ThreeScale.config.stubs(onpremises: true)
      get '/api_docs/services.json'
      assert_match '/api_docs/services/billing_api.json', response.body

      get '/api_docs/services/billing_api.json'
      assert_response :success
    end

    def test_index_and_show
      get api_docs_services_path(format: :json)
      index_result = JSON.parse(response.body)

      assert_response :success
      assert_equal ['host', 'apis'], index_result.keys

      api_expected_names = ['Service Management API', 'Account Management API', 'Analytics API', 'Billing API', 'Policy Registry API']
      assert_same_elements api_expected_names, index_result['apis'].map { |api| api['name'] }

      index_result['apis'].each_with_index do |api, index|
        get api_docs_service_path(format: :json, id: api['system_name'])
        show_result = JSON.parse(response.body)

        assert_response :success
        assert show_result.has_key?('basePath')
        assert show_result.has_key?('apis')
      end
    end

    def test_show_service_management
      backend_config = System::Application.config.backend_client
      get api_docs_service_path(format: :json, id: 'service_management_api')
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal "https://#{backend_config[:host]}", json['basePath']
    end
  end

  class MasterAccountServicesControllerTest < ApiDocs::ServicesControllerTest
    def setup
      login! master_account
    end

    def test_show_onprem_account_management_api
      # The test must be in this order to check also that the show will work next times after calling to it from master and onpremises true
      ThreeScale.config.stubs(onpremises: true)
      get '/api_docs/services/account_management_api.json'

      select_endpoint = Proc.new { |api| api['path'] == '/admin/api/account_plans/{id}.xml' }
      ThreeScale.config.stubs(onpremises: false)
      get '/api_docs/services/account_management_api.json'
      assert_not_empty JSON.parse(response.body)['apis'].select(&select_endpoint)

      ThreeScale.config.stubs(onpremises: true)
      get '/api_docs/services/account_management_api.json'
      assert_empty JSON.parse(response.body)['apis'].select(&select_endpoint)
    end

    def test_index_and_show
      expected_names = {
          saas: ['Service Management API', 'Account Management API', 'Analytics API', 'Billing API', 'Master API', 'Policy Registry API'],
          onpremises: ['Service Management API', 'Account Management API', 'Analytics API', 'Master API', 'Policy Registry API']
      }

      [true, false].each do |onpremises|
        ThreeScale.stubs(master_on_premises?: onpremises)
        get api_docs_services_path(format: :json)
        index_result = JSON.parse(response.body)

        assert_response :success
        assert_equal ['host', 'apis'], index_result.keys

        api_expected_names = expected_names[(onpremises ? :onpremises : :saas)]
        assert_same_elements api_expected_names, index_result['apis'].map { |api| api['name'] }

        index_result['apis'].each_with_index do |api, index|
          get api_docs_service_path(format: :json, id: api['system_name'])
          show_result = JSON.parse(response.body)

          assert_response :success
          assert show_result.has_key?('basePath')
          assert show_result.has_key?('apis')
        end
      end
    end
  end

  class ApiFileTest < ActiveSupport::TestCase

    ApiFile = ApiDocs::ServicesController::ApiFile

    def test_backend_base_host
      System::Application.config.stubs(backend_client: { url: 'example-localhost:3001', host: 'example.com' })
      api_json = ApiFile.new('API', 'service_management_api').json
      assert_equal 'example-localhost:3001', api_json['basePath']

      System::Application.config.stubs(backend_client: { host: 'example.com' })
      api_json = ApiFile.new('API', 'service_management_api').json
      assert_equal 'https://example.com', api_json['basePath']
    end

    def test_file_path
      Rails.application.config.three_scale.stubs(onpremises_api_docs_version: false)
      api_file = ApiFile.new('API', 'service_management_api')
      assert_not_match '(on-premises)', api_file.file_path.to_s

      Rails.application.config.three_scale.stubs(onpremises_api_docs_version: true)
      api_file = ApiFile.new('API', 'service_management_api')
      assert_match '(on-premises)', api_file.file_path.to_s
    end
  end

  class ClassMethods < ActiveSupport::TestCase

    def test_file_does_not_exist
      assert_raise(ApiDocs::ServicesController::ApiFileDoesNotExist) do
        ApiDocs::ServicesController.expects(:apis).returns([{system_name: :example_api, name: 'Alaska API'}])
        ApiDocs::ServicesController.verify_accessible_api_files_exist!
      end
    end
  end
end
