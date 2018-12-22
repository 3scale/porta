require 'test_helper'

class DeveloperPortal::Swagger::SpecControllerTest < ActionDispatch::IntegrationTest
  def setup
    @active_doc = FactoryBot.create(:api_docs_service, published: true)
    @provider = @active_doc.account
    host! @provider.domain
  end

  def test_show
    get developer_portal.swagger_spec_path(@active_doc), format: :json
    assert_response :success
    assert_equal(@active_doc.body, response.body)
  end

  def test_show_404
    get developer_portal.swagger_spec_path('undefined'), format: :json
    assert_response :not_found
    assert_equal({status: 'Not found'}.to_json, response.body)
  end
end
