# frozen_string_literal: true

require 'test_helper'

module CMS
  module Api
    class TemplatesTest < ActionDispatch::IntegrationTest

      def setup
        @provider = FactoryBot.create(:provider_account)
        host! @provider.admin_domain
      end

      test 'index' do
        FactoryBot.create(:cms_layout, provider: @provider)
        FactoryBot.create(:cms_partial, provider: @provider)
        FactoryBot.create(:cms_page, provider: @provider)
        FactoryBot.create(:cms_builtin_page, provider: @provider,
                          section: @provider.sections.root)

        get admin_api_cms_templates_path(format: :xml), params: { provider_key: @provider.provider_key }
        assert_response :success

        doc = Nokogiri::XML::Document.parse(@response.body)

        assert_equal 4, doc.xpath('/templates/*').size
        assert_equal 1, doc.xpath('/templates/partial').size
        assert_equal 0, doc.xpath('/templates/partial/draft').size
        assert_equal 1, doc.xpath('/templates/page').size
        assert_equal 1, doc.xpath('/templates/builtin_page').size
        assert_equal 1, doc.xpath('/templates/layout').size

        get admin_api_cms_templates_path(format: :json), params: { provider_key: @provider.provider_key }
        assert_response :success
      end

      test 'index with pagination' do
        23.times { FactoryBot.create(:cms_page, provider: @provider)  }

        # first page
        get admin_api_cms_templates_path(format: :xml), params: { provider_key: @provider.provider_key }
        assert_response :success
        doc = Nokogiri::XML::Document.parse(@response.body)

        assert_equal '1', doc.xpath('/templates/@current_page').text
        assert_equal '2', doc.xpath('/templates/@total_pages').text
        assert_equal '23', doc.xpath('/templates/@total_entries').text
        assert_equal 20, doc.xpath('/templates/*').size

        # second page
        get admin_api_cms_templates_path(format: :xml), params: { provider_key: @provider.provider_key, page: 2 }
        assert_response :success
        doc = Nokogiri::XML::Document.parse(@response.body)
        assert_equal 3, doc.xpath('/templates/*').size
      end

      test 'json index' do
        FactoryBot.create :cms_layout, provider: @provider, published: "the world will not be the same again.", draft: "The Simpsons"
        FactoryBot.create :cms_page,   provider: @provider, published: "mushrooms and pepperoni.",              draft: "yo que se"
        FactoryBot.create :cms_builtin_partial, provider: @provider, published: "storing the cheese at room temperature"

        get admin_api_cms_templates_path(format: :json), params: { provider_key: @provider.provider_key }
        assert_response :success

        assert_not_match 'mushrooms', response.body
        assert_equal 3, JSON.parse(response.body)['templates'].size
      end

      test 'explicit per_page parameter' do
        10.times { FactoryBot.create(:cms_layout, provider: @provider) }

        common = { provider_key: @provider.provider_key, format: :xml }
        get admin_api_cms_templates_path, params: common.merge(per_page: 5)
        assert_response :success
        doc = Nokogiri::XML::Document.parse(@response.body)

        assert_equal '5', doc.xpath('/templates/@per_page').text
        assert_equal '10', doc.xpath('/templates/@total_entries').text
        assert_equal '2', doc.xpath('/templates/@total_pages').text
        assert_equal '1', doc.xpath('/templates/@current_page').text
      end

      test 'index does not show email templates' do
        2.times { FactoryBot.create(:cms_page, provider: @provider)  }
        FactoryBot.create(:cms_email_template, provider: @provider)
        FactoryBot.create(:cms_builtin_legal_term, provider: @provider)

        # first page
        get admin_api_cms_templates_path, params: { provider_key: @provider.provider_key, format: :xml }
        assert_response :success
        doc = Nokogiri::XML::Document.parse(@response.body)

        assert_equal 2, doc.xpath('/templates/*').size
      end

      # TODO: check XML content
      test 'show partial' do
        partial = FactoryBot.create(:cms_partial, provider: @provider)

        get admin_api_cms_template_path(partial), params: { provider_key: @provider.provider_key, id: partial.id, format: :xml }
        assert_response :success
      end

      test 'show builtin page' do
        builtin = FactoryBot.create(:cms_builtin_page, provider: @provider)

        get admin_api_cms_template_path(builtin), params: { provider_key: @provider.provider_key, id: builtin.id, format: :xml }
        assert_response :success

        doc = Nokogiri::XML::Document.parse(@response.body)
        assert_empty doc.xpath('/page/path')
      end

      test 'show static build in page' do
        static = FactoryBot.create(:cms_builtin_static_page, provider: @provider)

        get admin_api_cms_template_path(static, format: :json), params: { provider_key: @provider.provider_key, id: static.id }

        assert_response :success
        assert_equal static.system_name, JSON.parse(response.body)['builtin_page']['system_name']

        get admin_api_cms_template_path(static, format: :xml), params: { provider_key: @provider.provider_key, id: static.id }
        assert_response :success

        doc = Nokogiri::XML::Document.parse(response.body)
        assert_equal static.system_name, doc.xpath("//builtin_page/system_name").text
      end

      test 'show page' do
        page = FactoryBot.create(:cms_page, provider: @provider, path: '/cool')
        get admin_api_cms_template_path(page), params: { provider_key: @provider.provider_key, id: page.id, format: :xml }
        assert_response :success

        doc = Nokogiri::XML::Document.parse(@response.body)
        assert_equal '/cool', doc.xpath('/page/path').text
      end

      test 'publish' do
        page = FactoryBot.create(:cms_page, provider: @provider, draft: 'new', published: 'old' )

        put publish_admin_api_cms_template_path(page), params: { provider_key: @provider.provider_key, format: :xml }
        assert_response :success

        assert_equal 'new', page.reload.published
      end

      test 'invalid update' do
        page = FactoryBot.create(:cms_page, provider: @provider)
        put admin_api_cms_template_path(page), params: { provider_key: @provider.provider_key, id: page.id, path: 'invalid-path/', format: :xml }
        assert_response :unprocessable_entity
      end

      test 'update' do
        new_layout = FactoryBot.create(:cms_layout, system_name: 'NEW', provider: @provider)
        page = FactoryBot.create(:cms_page, provider: @provider)

        put admin_api_cms_template_path(page), params: { provider_key: @provider.provider_key, id: page.id, format: :xml,
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
                                                         format: :xml, template: { layout_id: new_layout.id }
        }

        assert_response :success
        assert_equal new_layout, page.reload.layout
      end

      test 'create with missing or invalid type fails' do
        post admin_api_cms_templates_path, params: { provider_key: @provider.provider_key, format: :xml, type: 'INVALID' }
        assert_response :not_acceptable

        post admin_api_cms_templates_path, params: { provider_key: @provider.provider_key, format: :xml }
        assert_response :not_acceptable
      end

      test 'create' do
        layout = FactoryBot.create(:cms_layout, :system_name => 'new-layout', :provider => @provider)

        post admin_api_cms_templates_path, params: { provider_key: @provider.provider_key, format: :xml,
          type: 'page',
          path: '/',
          content_type: 'text/html',
          title: 'Rake 5000',
          layout_name: 'new-layout' }

        assert_response :success

        doc = Nokogiri::XML::Document.parse(@response.body)
        id = doc.xpath('//id').text
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

        page = CMS::Page.find JSON.parse(response.body)['page']['id']
        assert_equal section, page.section

        # publish this page
        put publish_admin_api_cms_template_path(page, format: :json), params: { provider_key: @provider.provider_key }
        assert_response :success

        host! @provider.domain

        get "/important/page.html"

        assert_response :success

        assert_equal "The page Over 9000", response.body

      end

      test 'create a layout' do
        post admin_api_cms_templates_path, params: { provider_key: @provider.provider_key, format: :xml,
          type: 'layout',
          system_name: 'foo',
          draft: 'bar',
          title: 'a title',
          liquid_enabled: true
        }

        assert_response :success
        doc = Nokogiri::XML::Document.parse(@response.body)
        assert_equal 'foo', doc.xpath('//system_name').text
        assert_equal 'bar', doc.xpath('//draft').text
        assert_equal 'a title', doc.xpath('//title').text
        assert_equal 'true', doc.xpath('//liquid_enabled').text
      end

      test 'create a partial' do
        post admin_api_cms_templates_path, params: { provider_key: @provider.provider_key, format: :xml,
          type: 'partial',
          system_name: 'foo',
          draft: 'bar'
        }
        assert_response :success
        doc = Nokogiri::XML::Document.parse(@response.body)

        assert_equal 'foo', doc.xpath('//system_name').text
        assert_equal 'bar', doc.xpath('//draft').text
      end
    end
  end
end
