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
      partial = FactoryBot.create(:cms_builtin_partial, provider: @provider)

      get :show, params: { id: partial.id, format: :json, access_token: @token }

      assert_response :success
      assert_equal(
        %w[id type created_at updated_at system_name draft published],
        JSON.parse(response.body).keys
      )
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

      def test_create_page_section_id_unknown
        post :create, params: { section_id: 100, type: 'page',
                                title: 'About', path: '/about', format: :json, access_token: @token }

        assert_response :unprocessable_entity
      end

      def test_create_page_section_name_unknown
        post :create, params: { section_name: 'non-existent', type: 'page',
                                title: 'About', path: '/about', format: :json, access_token: @token }

        assert_response :unprocessable_entity
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

      def test_create_page_layout_id_unknown
        post :create, params: { layout_id: 100, type: 'page',
                                title: 'About', path: '/about', format: :json, access_token: @token }

        assert_response :unprocessable_entity
      end

      def test_create_page_layout_name_unknown
        post :create, params: { layout_name: 'non-existent', type: 'page',
                                title: 'About', path: '/about', format: :json, access_token: @token }

        assert_response :unprocessable_entity
      end
    end

    class Update < TemplatesPageTest
      def test_update_page_section_nil
        page = FactoryBot.create(:cms_page, provider: @provider, section: @section)

        put :update, params: { id: page.id, title: 'About', path: '/about', format: :json, access_token: @token }

        assert_equal @section, page.reload.section
      end

      def test_update_page_section_id
        page = FactoryBot.create(:cms_page, provider: @provider)

        put :update, params: { id: page.id, section_id: @section.id,
                                title: 'About', path: '/about', format: :json, access_token: @token }

        assert_equal @section, page.reload.section
      end

      def test_update_page_section_name
        page = FactoryBot.create(:cms_page, provider: @provider)

        put :update, params: { id: page.id, section_name: @section.system_name,
                                title: 'About', path: '/about', format: :json, access_token: @token }

        assert_equal @section, page.reload.section
      end

      def test_update_page_section_id_unknown
        page = FactoryBot.create(:cms_page, provider: @provider)

        put :update, params: { id: page.id, section_id: 100,
                               title: 'About', path: '/about', format: :json, access_token: @token }

        assert_response :unprocessable_entity
      end

      def test_update_page_section_name_unknown
        page = FactoryBot.create(:cms_page, provider: @provider)

        put :update, params: { id: page.id, section_name: 'non-existent',
                               title: 'About', path: '/about', format: :json, access_token: @token }

        assert_response :unprocessable_entity
      end

      def test_update_page_layout_nil
        page = FactoryBot.create(:cms_page, provider: @provider, layout: @layout)

        put :update, params: { id: page.id, title: 'About', path: '/about', format: :json, access_token: @token }

        assert_equal @layout, page.reload.layout
      end

      def test_update_page_layout_empty
        page = FactoryBot.create(:cms_page, provider: @provider, layout: @layout)

        put :update, params: { id: page.id, layout_id: '', title: 'About', path: '/about', format: :json, access_token: @token }

        assert_nil page.reload.layout
      end

      def test_update_page_layout_id
        page = FactoryBot.create(:cms_page, provider: @provider)

        put :update, params: { id: page.id, layout_id: @layout.id,
                                title: 'About', path: '/about', format: :json, access_token: @token }

        assert_equal @layout, page.reload.layout
      end

      def test_update_page_layout_name
        page = FactoryBot.create(:cms_page, provider: @provider)

        put :update, params: { id: page.id, layout_name: @layout.system_name,
                                title: 'About', path: '/about', format: :json, access_token: @token }

        assert_equal @layout, page.reload.layout
      end

      def test_update_page_layout_id_unknown
        page = FactoryBot.create(:cms_page, provider: @provider)

        put :update, params: { id: page.id, layout_id: 100,
                               title: 'About', path: '/about', format: :json, access_token: @token }

        assert_response :unprocessable_entity
      end

      def test_update_page_layout_name_unknown
        page = FactoryBot.create(:cms_page, provider: @provider)

        put :update, params: { id: page.id, layout_name: 'non-existent',
                               title: 'About', path: '/about', format: :json, access_token: @token }

        assert_response :unprocessable_entity
      end
    end
  end
end
