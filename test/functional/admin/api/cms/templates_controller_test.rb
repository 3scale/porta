require 'test_helper'

class Admin::Api::CMS::TemplatesControllerTest < ActionController::TestCase

  def setup
    @provider     = FactoryBot.create(:provider_account)
    @request.host = @provider.admin_domain

    login_provider @provider
  end

  def test_show
    CMS::Portlet.available.each do |portlet_type|
      portlet = FactoryBot.create(:cms_portlet, provider: @provider,
        portlet_type: portlet_type.to_s, type: portlet_type.to_s)

      get :show, id: portlet.id, format: :xml

      assert_response :success
      assert_equal 0, xml_elements_by_key(@response.body, 'builtin_partial').count
      assert_equal 1, xml_elements_by_key(@response.body, 'partial').count
    end
  end

  def test_show_builtin_partial
    partial = FactoryBot.create(:cms_builtin_partial, provider: @provider)

    get :show, id: partial.id, format: :xml

    assert_response :success
    assert_equal 1, xml_elements_by_key(@response.body, 'builtin_partial').count
    assert_equal 0, xml_elements_by_key(@response.body, 'partial').count
  end

  def test_create
    post :create, section_name: { '0' => 'foooo' }, template: { type: 'page',
      title: 'About', path: '/about' }, format: :json

    assert_response :success
  end

  def test_destroy_success
    page = FactoryBot.create(:cms_page, provider: @provider)

    delete :destroy, id: page.id, format: :json

    assert_response :success
  end

  def test_destroy_locked
    # builtin pages cannot be destroyed
    page = FactoryBot.create(:cms_builtin_partial, provider: @provider)

    delete :destroy, id: page.id, format: :json

    assert_response :locked
  end

  private

  def xml_elements_by_key(xml, key)
    Nokogiri::XML::Document.parse(xml).document.children.xpath("//#{key}")
  end
end
