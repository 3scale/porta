# frozen_string_literal: true

require 'test_helper'

module CMS
  module Api
    class SectionsTest < ActionDispatch::IntegrationTest

      def setup
        @provider = FactoryBot.create(:provider_account)
        host! @provider.admin_domain
      end

      def create_section
        FactoryBot.create :cms_section, :provider => @provider, parent: @provider.sections.root
      end

      test 'index' do
        20.times { create_section }

        get admin_api_cms_sections_path, params: { provider_key: @provider.provider_key, format: :xml }
        assert_response :success

        doc = Nokogiri::XML::Document.parse(@response.body)

        assert_equal 20, doc.xpath('/sections/*').size
      end

      test 'index with pagination' do
        20.times { create_section  }

        # first page
        get admin_api_cms_sections_path, params: { provider_key: @provider.provider_key, format: :xml }
        assert_response :success
        doc = Nokogiri::XML::Document.parse(@response.body)

        assert_equal '1', doc.xpath('/sections/@current_page').text
        assert_equal '2', doc.xpath('/sections/@total_pages').text
        assert_equal '21', doc.xpath('/sections/@total_entries').text
        assert_equal 20, doc.xpath('/sections/*').size

        # second page
        get admin_api_cms_sections_path, params: { provider_key: @provider.provider_key, page: 2, format: :xml }
        assert_response :success
        doc = Nokogiri::XML::Document.parse(@response.body)
        assert_equal 1, doc.xpath('/sections/*').size
      end

      test 'explicit per_page parameter' do
        10.times { create_section  }

        common = { provider_key: @provider.provider_key, format: :xml }
        get admin_api_cms_sections_path, params: common.merge(per_page: 5)
        assert_response :success
        doc = Nokogiri::XML::Document.parse(@response.body)

        assert_equal '5', doc.xpath('/sections/@per_page').text
        assert_equal '11', doc.xpath('/sections/@total_entries').text
        assert_equal '3', doc.xpath('/sections/@total_pages').text
        assert_equal '1', doc.xpath('/sections/@current_page').text
      end

      test 'show section' do
        section = create_section
        get admin_api_cms_section_path(section), params: { provider_key: @provider.provider_key, format: :xml }
        assert_response :success

        doc = Nokogiri::XML::Document.parse(@response.body)

        assert_equal section.id.to_s, doc.xpath('/section/id').text
        assert_equal section.created_at.xmlschema, doc.xpath('/section/created_at').text
        assert_equal section.updated_at.xmlschema, doc.xpath('/section/updated_at').text
        assert_equal section.parent_id.to_s, doc.xpath('/section/parent_id').text
        assert_equal section.system_name, doc.xpath('/section/system_name').text
        assert_equal section.title, doc.xpath('/section/title').text
      end

      test 'find section by system name' do
        get admin_api_cms_section_path(id: 'root', format: :json), params: { provider_key: @provider.provider_key }
        assert_response :success
        assert_equal 'root', JSON.parse(response.body)['section']['system_name']
      end

      test 'invalid system name or id' do
        get admin_api_cms_section_path(id: 'lamb', format: :json), params: { provider_key: @provider.provider_key }
        assert_response :not_found
      end

      test 'update' do
        section = create_section
        put admin_api_cms_section_path(section), params: { provider_key: @provider.provider_key, format: :xml, title: 'foo' }
        assert_response :success

        section.reload
        assert_equal 'foo', section.title
      end

      test 'create' do

        post admin_api_cms_sections_path, params: { provider_key: @provider.provider_key, format: :xml, title: 'Foo Bar Lol' }

        assert_response :success

        doc = Nokogiri::XML::Document.parse(@response.body)
        id = doc.xpath('//id').text
        section = @provider.sections.find(id.to_i)

        assert_equal 'Foo Bar Lol', section.title
      end
    end

  end
end
