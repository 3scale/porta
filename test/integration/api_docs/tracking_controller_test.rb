# frozen_string_literal: true

require 'test_helper'

class ApiDocs::TrackingControllerTest < ActionDispatch::IntegrationTest
  def setup
    provider = FactoryBot.create(:provider_account)
    login_provider provider
  end

  test 'disables x_content_type_options header' do
    get api_docs_check_path(format: :json)
    refute_includes response.headers, 'X-Content-Type-Options'
  end
end
