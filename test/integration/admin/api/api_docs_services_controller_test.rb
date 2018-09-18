# frozen_string_literal: true

require 'test_helper'

class Admin::Api::ApiDocsServicesControllerTest < ActionDispatch::IntegrationTest

  def setup
    login! current_account
  end

  class MasterAccountTest < Admin::Api::ApiDocsServicesControllerTest
    def test_index_json_saas
      get admin_api_docs_services_path
      assert_response :success
    end

    def test_index_json_on_premises
      ThreeScale.stubs(master_on_premises?: true)
      get admin_api_docs_services_path
      assert_response :forbidden
    end

    private

    def current_account
      master_account
    end
  end
end
