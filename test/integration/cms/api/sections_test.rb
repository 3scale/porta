# frozen_string_literal: true

require 'test_helper'

module CMS
  module Api
    class SectionsTest < ActionDispatch::IntegrationTest
      def setup
        @provider = FactoryBot.create(:provider_account)
        host! @provider.external_admin_domain
      end

      def create_section
        FactoryBot.create :cms_section, :provider => @provider, parent: @provider.sections.root
      end

      test 'index' do
        20.times { create_section }

        get admin_api_cms_sections_path, params: { provider_key: @provider.provider_key, format: :json }
        assert_response :success
        assert_equal 20, response.parsed_body['sections'].size
      end

      test 'index with pagination' do
        20.times { create_section  }

        # first page
        get admin_api_cms_sections_path, params: { provider_key: @provider.provider_key, format: :json }
        assert_response :success

        assert_equal 20, response.parsed_body['sections'].size
        assert_equal(
          { per_page: 20, total_entries: 21, total_pages: 2, current_page: 1 },
          response.parsed_body['metadata'].symbolize_keys
        )

        # second page
        get admin_api_cms_sections_path, params: { provider_key: @provider.provider_key, page: 2, format: :json }
        assert_response :success

        assert_equal 1, response.parsed_body['sections'].size
        assert_equal(
          { per_page: 20, total_entries: 21, total_pages: 2, current_page: 2 },
          response.parsed_body['metadata'].symbolize_keys
        )
      end

      test 'explicit per_page parameter' do
        10.times { create_section  }

        common = { provider_key: @provider.provider_key, format: :json }
        get admin_api_cms_sections_path, params: common.merge(per_page: 5)
        assert_response :success

        assert_equal 5, response.parsed_body['sections'].size
        assert_equal(
          { per_page: 5, total_entries: 11, total_pages: 3, current_page: 1 },
          response.parsed_body['metadata'].symbolize_keys
        )
      end

      test 'show section' do
        section = create_section
        get admin_api_cms_section_path(section), params: { provider_key: @provider.provider_key, format: :json }
        assert_response :success

        assert_equal(
          %w[id created_at updated_at title system_name public parent_id partial_path],
          response.parsed_body['section'].keys
        )
      end

      test 'find section by system name' do
        get admin_api_cms_section_path(id: 'root', format: :json), params: { provider_key: @provider.provider_key }
        assert_response :success
        assert_equal 'root', JSON.parse(response.body)['builtin_section']['system_name']
      end

      test 'invalid system name or id' do
        get admin_api_cms_section_path(id: 'lamb', format: :json), params: { provider_key: @provider.provider_key }
        assert_response :not_found
      end

      test 'update' do
        section = create_section
        put admin_api_cms_section_path(section), params: {
          provider_key: @provider.provider_key,
          format: :json,
          title: 'foo'
        }
        assert_response :success

        section.reload
        assert_equal 'foo', section.title
      end

      test 'create' do
        post admin_api_cms_sections_path, params: {
          provider_key: @provider.provider_key,
          format: :json,
          title: 'Foo Bar Lol'
        }

        assert_response :success

        id = response.parsed_body['section']['id']
        section = @provider.sections.find(id.to_i)

        assert_equal 'Foo Bar Lol', section.title
      end
    end

    class SystemNameTest < ActionDispatch::IntegrationTest
      def setup
        @provider = FactoryBot.create(:provider_account)
        host! @provider.external_admin_domain
      end

      test 'create without title' do
        post admin_api_cms_sections_path, params: { provider_key: @provider.provider_key, format: :xml, public: true}

        assert_response 422

        doc = Nokogiri::XML::Document.parse(@response.body)
        error = doc.xpath('//error').text

        assert_match "Title can't be blank", error
      end

      test 'create with title but without system_name' do
        expected_title = 'New Section'
        expected_sysname = 'New Section'

        post admin_api_cms_sections_path, params: { provider_key: @provider.provider_key, format: :xml, title: expected_title}

        assert_response :success

        doc = Nokogiri::XML::Document.parse(@response.body)
        title = doc.xpath('//title').text
        sysname = doc.xpath('//system_name').text

        assert_equal expected_title, title
        assert_equal expected_sysname, sysname
      end

      test 'create with title and system_name' do
        expected_title = 'New Section'
        expected_sysname = 'new_section'

        post admin_api_cms_sections_path, params: { provider_key: @provider.provider_key, format: :xml,
                                                    title: expected_title, system_name: expected_sysname }

        assert_response :success

        doc = Nokogiri::XML::Document.parse(@response.body)
        title = doc.xpath('//title').text
        sysname = doc.xpath('//system_name').text

        assert_equal expected_title, title
        assert_equal expected_sysname, sysname
      end
    end
  end
end
