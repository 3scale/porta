# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::ApiDocs::ServicesControllerTest < ActionDispatch::IntegrationTest
  include DeveloperPortal::Engine.routes.url_helpers

  def setup
    buyer = FactoryBot.create(:buyer_account)
    login_buyer(buyer)
  end

  test 'disables x_content_type_options header' do
    get api_docs_services_path(format: :json)
    refute_includes response.headers, 'X-Content-Type-Options'
  end
end
