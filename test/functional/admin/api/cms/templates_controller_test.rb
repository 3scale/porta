# frozen_string_literal: true

require 'test_helper'

class Admin::Api::CMS::TemplatesControllerTest < ActionController::TestCase

  def setup
    @provider     = FactoryBot.create(:provider_account)
    host! @provider.external_admin_domain
    @token = FactoryBot.create(:access_token, owner: @provider.admin_users.first!, scopes: %w[cms]).value
  end

  class TemplatesControllerMethodsTest < Admin::Api::CMS::TemplatesControllerTest
    def test_show
      CMS::Portlet.available.each do |portlet_type|
        portlet = FactoryBot.create(:cms_portlet, provider: @provider,
          portlet_type: portlet_type.to_s, type: portlet_type.to_s)

        get :show, params: { id: portlet.id, format: :xml, access_token: @token }

        assert_response :success
        assert_equal 0, xml_elements_by_key(@response.body, 'builtin_partial').count
        assert_equal 1, xml_elements_by_key(@response.body, 'partial').count
      end
    end

    def test_show_builtin_partial
      partial = FactoryBot.create(:cms_builtin_partial, provider: @provider)

      get :show, params: { id: partial.id, format: :xml, access_token: @token }

      assert_response :success
      assert_equal 1, xml_elements_by_key(@response.body, 'builtin_partial').count
      assert_equal 0, xml_elements_by_key(@response.body, 'partial').count
    end

    def test_create
      post :create, params: { type: 'page', title: 'About', path: '/about', format: :json, access_token: @token }

      assert_response :success
    end

    def test_update
      page = FactoryBot.create(:cms_page, provider: @provider)

      put :update, params: { id: page.id, type: 'page', title: 'About', path: '/about', format: :json, access_token: @token }

      assert_response :success
    end

    def test_destroy_success
      page = FactoryBot.create(:cms_page, provider: @provider)

      delete :destroy, params: { id: page.id, format: :json, access_token: @token }

      assert_response :success
    end

    def test_destroy_locked
      # builtin pages cannot be destroyed
      page = FactoryBot.create(:cms_builtin_partial, provider: @provider)

      delete :destroy, params: { id: page.id, format: :json, access_token: @token }

      assert_response :locked
    end

    private

    def xml_elements_by_key(xml, key)
      Nokogiri::XML::Document.parse(xml).document.children.xpath("//#{key}")
    end
  end

  class TemplatesPageTest < Admin::Api::CMS::TemplatesControllerTest
    def setup
      super
      @section = FactoryBot.create :cms_section, provider: @provider, parent: @provider.sections.root
      @layout = FactoryBot.create :cms_layout, provider: @provider
    end

    class Create < TemplatesPageTest
      def test_create_page_section_nil
        post :create, params: { type: 'page', title: 'About', path: '/about', format: :json, access_token: @token }

        page = @provider.pages.last
        assert_equal @provider.sections.root, page.section
      end

      def test_create_page_section_id
        post :create, params: { section_id: @section.id, type: 'page',
                                title: 'About', path: '/about', format: :json, access_token: @token }

        page = @provider.pages.last
        assert_equal @section, page.section
      end

      def test_create_page_section_name
        post :create, params: { section_name: @section.system_name, type: 'page',
                                title: 'About', path: '/about', format: :json, access_token: @token }

        page = @provider.pages.last
        assert_equal @section, page.section
      end

      def test_create_page_layout_nil
        post :create, params: { type: 'page', title: 'About', path: '/about', format: :json, access_token: @token }

        page = @provider.pages.last
        assert_nil page.layout
      end

      def test_create_page_layout_id
        post :create, params: { layout_id: @layout.id, type: 'page',
                                title: 'About', path: '/about', format: :json, access_token: @token }

        page = @provider.pages.last
        assert_equal @layout, page.layout
      end

      def test_create_page_layout_name
        post :create, params: { layout_name: @layout.system_name, type: 'page',
                                title: 'About', path: '/about', format: :json, access_token: @token }

        page = @provider.pages.last
        assert_equal @layout, page.layout
      end
    end

    class Update < TemplatesPageTest
      def test_update_page_section_nil
        page = FactoryBot.create(:cms_page, provider: @provider, section: @section)

        put :update, params: { id: page.id, type: 'page', title: 'About', path: '/about', format: :json, access_token: @token }

        assert_equal @section, page.reload.section
      end

      def test_update_page_section_id
        page = FactoryBot.create(:cms_page, provider: @provider)

        put :update, params: { id: page.id, section_id: @section.id, type: 'page',
                                title: 'About', path: '/about', format: :json, access_token: @token }

        assert_equal @section, page.reload.section
      end

      def test_update_page_section_name
        page = FactoryBot.create(:cms_page, provider: @provider)

        put :update, params: { id: page.id, section_name: @section.system_name, type: 'page',
                                title: 'About', path: '/about', format: :json, access_token: @token }

        assert_equal @section, page.reload.section
      end

      def test_update_page_layout_nil
        page = FactoryBot.create(:cms_page, provider: @provider, layout: @layout)

        put :update, params: { id: page.id, type: 'page', title: 'About', path: '/about', format: :json, access_token: @token }

        assert_equal @layout, page.reload.layout
      end

      def test_update_page_layout_id
        page = FactoryBot.create(:cms_page, provider: @provider)

        put :update, params: { id: page.id, layout_id: @layout.id, type: 'page',
                                title: 'About', path: '/about', format: :json, access_token: @token }

        assert_equal @layout, page.reload.layout
      end

      def test_update_page_layout_name
        page = FactoryBot.create(:cms_page, provider: @provider)

        put :update, params: { id: page.id, layout_name: @layout.system_name, type: 'page',
                                title: 'About', path: '/about', format: :json, access_token: @token }

        assert_equal @layout, page.reload.layout
      end
    end
  end
end
