# frozen_string_literal: true

require 'test_helper'

module CMS
  module Api
    class TemplatesTest < ActionDispatch::IntegrationTest
      def setup
        @provider = FactoryBot.create(:provider_account)
        host! @provider.external_admin_domain
      end

      test 'index' do
        FactoryBot.create(:cms_layout, provider: @provider)
        FactoryBot.create(:cms_partial, provider: @provider)
        FactoryBot.create(:cms_page, provider: @provider)
        FactoryBot.create(:cms_builtin_page, provider: @provider,
                          section: @provider.sections.root)

        get admin_api_cms_templates_path(format: :json), params: { provider_key: @provider.provider_key }
        assert_response :success

        templates = response.parsed_body['collection']

        assert_equal 4, templates.size
        assert_equal 1, templates.select { |templ| templ['type'] == 'partial' }.size
        assert_nil templates.find { |templ| templ['type'] == 'partial' }['draft']
        assert_equal 1, templates.select { |templ| templ['type'] == 'page' }.size
        assert_equal 1, templates.select { |templ| templ['type'] == 'builtin_page' }.size
        assert_equal 1, templates.select { |templ| templ['type'] == 'layout' }.size

        get admin_api_cms_templates_path(format: :json), params: { provider_key: @provider.provider_key }
        assert_response :success
      end

      test 'index with pagination' do
        23.times { FactoryBot.create(:cms_page, provider: @provider)  }

        # first page
        get admin_api_cms_templates_path(format: :json), params: { provider_key: @provider.provider_key }
        assert_response :success

        assert_equal 20, response.parsed_body['collection'].size
        assert_equal(
          { per_page: 20, total_entries: 23, total_pages: 2, current_page: 1 },
          response.parsed_body['metadata'].symbolize_keys
        )

        # second page
        get admin_api_cms_templates_path(format: :json), params: { provider_key: @provider.provider_key, page: 2 }
        assert_response :success

        assert_equal 3, response.parsed_body['collection'].size
        assert_equal(
          { per_page: 20, total_entries: 23, total_pages: 2, current_page: 2 },
          response.parsed_body['metadata'].symbolize_keys
        )
      end

      test 'json index' do
        FactoryBot.create :cms_layout, provider: @provider, published: "the world will not be the same again.", draft: "The Simpsons"
        FactoryBot.create :cms_page,   provider: @provider, published: "mushrooms and pepperoni.",              draft: "yo que se"
        FactoryBot.create :cms_builtin_partial, provider: @provider, published: "storing the cheese at room temperature"

        get admin_api_cms_templates_path(format: :json), params: { provider_key: @provider.provider_key }
        assert_response :success

        assert_not_match 'mushrooms', response.body
        assert_equal 3, JSON.parse(response.body)['collection'].size
      end

      test 'explicit per_page parameter' do
        10.times { FactoryBot.create(:cms_layout, provider: @provider) }

        common = { provider_key: @provider.provider_key, format: :json }
        get admin_api_cms_templates_path, params: common.merge(per_page: 5)
        assert_response :success

        assert_equal 5, response.parsed_body['collection'].size
        assert_equal(
          { per_page: 5, total_entries: 10, total_pages: 2, current_page: 1 },
          response.parsed_body['metadata'].symbolize_keys
        )
      end

      test 'index does not show email templates' do
        2.times { FactoryBot.create(:cms_page, provider: @provider)  }
        FactoryBot.create(:cms_email_template, provider: @provider)
        FactoryBot.create(:cms_builtin_legal_term, provider: @provider)

        # first page
        get admin_api_cms_templates_path, params: { provider_key: @provider.provider_key, format: :json }
        assert_response :success

        assert_equal 2, response.parsed_body['collection'].size
      end

      test 'index filters by type' do
        FactoryBot.create_list(:cms_page, 5, provider: @provider)
        FactoryBot.create_list(:cms_partial, 2, provider: @provider)

        get admin_api_cms_templates_path, params: { provider_key: @provider.provider_key, type: 'partial' }

        assert_response :success
        assert_equal 2, response.parsed_body['collection'].size
      end

      test 'index filters by section_id' do
        section = FactoryBot.create(:cms_section, provider: @provider, parent: @provider.sections.root)
        FactoryBot.create_list(:cms_page, 5, provider: @provider)
        FactoryBot.create_list(:cms_page, 2, provider: @provider, section_id: section.id)

        get admin_api_cms_templates_path, params: { provider_key: @provider.provider_key, section_id: section.id }

        assert_response :success
        assert_equal 2, response.parsed_body['collection'].size
      end

      # TODO: check XML content
      test 'show partial' do
        partial = FactoryBot.create(:cms_partial, provider: @provider)

        get admin_api_cms_template_path(partial), params: { provider_key: @provider.provider_key, id: partial.id, format: :json }
        assert_response :success
      end

      test 'show builtin page' do
        builtin = FactoryBot.create(:cms_builtin_page, provider: @provider)

        get admin_api_cms_template_path(builtin), params: { provider_key: @provider.provider_key, id: builtin.id, format: :json }
        assert_response :success

        assert_nil response.parsed_body['path']
      end

      test 'show static build in page' do
        static = FactoryBot.create(:cms_builtin_static_page, provider: @provider)

        get admin_api_cms_template_path(static, format: :json), params: { provider_key: @provider.provider_key, id: static.id }

        assert_response :success
        assert_equal static.system_name, JSON.parse(response.body)['system_name']

        get admin_api_cms_template_path(static, format: :json), params: { provider_key: @provider.provider_key, id: static.id }
        assert_response :success

        assert_equal static.system_name, response.parsed_body['system_name']
      end

      test 'show page' do
        page = FactoryBot.create(:cms_page, provider: @provider, path: '/cool')

        get admin_api_cms_template_path(page), params: { provider_key: @provider.provider_key, id: page.id, format: :json }
        assert_response :success

        assert_equal '/cool', response.parsed_body['path']
      end

      test "show a page with HTML inside the content" do
        html_content = '<html><body><p>This is a test</p></body></html>'
        page = FactoryBot.create(:cms_page, provider: @provider, path: '/cool', published: html_content)
        get admin_api_cms_template_path(page), params: { provider_key: @provider.provider_key, id: page.id, format: :json }
        assert_response :success

        assert_equal html_content, response.parsed_body['published']
      end

      test 'publish' do
        page = FactoryBot.create(:cms_page, provider: @provider, draft: 'new', published: 'old' )

        put publish_admin_api_cms_template_path(page), params: { provider_key: @provider.provider_key, format: :json }
        assert_response :success

        assert_equal 'new', page.reload.published
      end

      test 'invalid update' do
        page = FactoryBot.create(:cms_page, provider: @provider)
        put admin_api_cms_template_path(page), params: { provider_key: @provider.provider_key, id: page.id, path: 'invalid-path/', format: :json }
        assert_response :unprocessable_entity
      end

      test 'update' do
        new_layout = FactoryBot.create(:cms_layout, system_name: 'NEW', provider: @provider)
        page = FactoryBot.create(:cms_page, provider: @provider)

        put admin_api_cms_template_path(page), params: { provider_key: @provider.provider_key, id: page.id, format: :json,
                                                         title: 'new title', content_type: 'text/xml', layout_name: 'NEW' }

        assert_response :success

        page.reload
        assert_equal 'new title', page.title
        assert_equal 'text/xml', page.content_type
        assert_equal new_layout, page.layout
      end

      test 'update - content type is multipart/form-data' do
        page   = FactoryBot.create(:cms_page, provider: @provider)
        params = {
          provider_key: @provider.provider_key,
          title:        'Alaska',
          draft:        '<p>Wildness</p>'
        }

        assert_not_equal page.draft, params[:draft]
        assert_not_equal page.title, params[:title]

        put admin_api_cms_template_path(page), params: params, headers: { 'CONTENT_TYPE': 'multipart/form-data' }

        page.reload

        assert_response :success
        assert_equal page.draft, params[:draft]
        assert_equal page.title, params[:title]
      end

      test 'update layout by id' do
        new_layout = FactoryBot.create(:cms_layout, :system_name => 'NEW', :provider => @provider)
        page = FactoryBot.create(:cms_page, :provider => @provider)

        put admin_api_cms_template_path(page), params: { provider_key: @provider.provider_key, id: page.id,
                                                         format: :json, layout_id: new_layout.id
        }

        assert_response :success
        assert_equal new_layout, page.reload.layout
      end

      test 'update ignores immutable fields' do
        page   = FactoryBot.create(:cms_page, provider: @provider)
        created_at = page.created_at
        updated_at = page.updated_at
        hidden = page.hidden?
        published = page.published.present?
        params = {
          provider_key: @provider.provider_key,
          title:        'Alaska',
          created_at:   Time.current + 1000,
          updated_at:   Time.current + 1000,
          hidden:       true,
          published:     true
        }

        put admin_api_cms_template_path(page), params: params
        page.reload

        assert_response :success
        assert_equal created_at, page.created_at
        assert_equal updated_at, page.updated_at
        assert_equal hidden, page.hidden?
        assert_equal published, page.published.present?
      end

      test 'create with missing or invalid type fails' do
        post admin_api_cms_templates_path, params: { provider_key: @provider.provider_key, format: :json,
                                                     type: 'INVALID', title: 'test template' }
        assert_response :unprocessable_entity

        post admin_api_cms_templates_path, params: { provider_key: @provider.provider_key, format: :json, title: 'test template' }
        assert_response :unprocessable_entity
      end

      test 'create' do
        layout = FactoryBot.create(:cms_layout, :system_name => 'new-layout', :provider => @provider)

        post admin_api_cms_templates_path, params: { provider_key: @provider.provider_key, format: :json,
          type: 'page',
          path: '/',
          content_type: 'text/html',
          title: 'Rake 5000',
          layout_name: 'new-layout' }

        assert_response :success

        id = response.parsed_body['id']
        page = @provider.pages.find(id.to_i)

        assert_equal 'Rake 5000', page.title
        assert_equal 'text/html', page.content_type
        assert_equal layout, page.layout
        assert_equal @provider.sections.root, page.section
      end

      test 'create a page within a section and check it out' do
        section = FactoryBot.create :cms_section, title: "important", parent: @provider.sections.root, provider: @provider

        post admin_api_cms_templates_path(format: :json), params: {
          provider_key: @provider.provider_key, type: "page", path: "/important/page.html",
          content_type: "text/html", title: "Over 9000", liquid_enabled: true,
          draft: "The page Over 9000", section_id: section.id
        }

        assert_response :success

        page = CMS::Page.find(JSON.parse(response.body)['id'])
        assert_equal section, page.section

        # publish this page
        put publish_admin_api_cms_template_path(page, format: :json), params: { provider_key: @provider.provider_key }
        assert_response :success

        host! @provider.internal_domain

        get "/important/page.html"

        assert_response :success

        assert_equal "The page Over 9000", response.body
      end

      test 'create a layout' do
        post admin_api_cms_templates_path, params: { provider_key: @provider.provider_key, format: :json,
          type: 'layout',
          system_name: 'foo',
          draft: 'bar',
          title: 'a title',
          liquid_enabled: true
        }

        assert_response :success

        layout = response.parsed_body
        assert_equal 'foo', layout['system_name']
        assert_equal 'bar', layout['draft']
        assert_equal 'a title', layout['title']
        assert_equal true, layout['liquid_enabled']
      end

      test 'create a partial' do
        post admin_api_cms_templates_path, params: { provider_key: @provider.provider_key, format: :json,
          type: 'partial',
          system_name: 'foo',
          draft: 'bar'
        }

        assert_response :success

        partial = response.parsed_body
        assert_equal 'foo', partial['system_name']
        assert_equal 'bar', partial['draft']
      end
    end
  end
end
