# frozen_string_literal: true

require 'test_helper'

module CMS
  module Api
    class FilesTest < ActionDispatch::IntegrationTest

      def setup
        @provider = FactoryBot.create(:provider_account)
        host! @provider.external_admin_domain
      end

      def create_file
        FactoryBot.create(:cms_file, :provider => @provider)
      end

      def attachment_for_upload
        fixture_file_upload(Rails.root.join('test', 'fixtures', 'wide.jpg'),' image/jpeg')
      end

      test 'index' do
        21.times { create_file }
        get admin_api_cms_files_path, params: { provider_key: @provider.provider_key, format: :xml }
        assert_response :success

        doc = Nokogiri::XML::Document.parse(@response.body)
        assert_equal 20, doc.xpath('/files/*').size
      end

      test 'index with pagination' do
        21.times { create_file  }

        # first page
        get admin_api_cms_files_path, params: { provider_key: @provider.provider_key, format: :xml }
        assert_response :success
        doc = Nokogiri::XML::Document.parse(@response.body)

        assert_equal '1', doc.xpath('/files/@current_page').text
        assert_equal '2', doc.xpath('/files/@total_pages').text
        assert_equal '21', doc.xpath('/files/@total_entries').text
        assert_equal 20, doc.xpath('/files/*').size

        # second page
        get admin_api_cms_files_path, params: { provider_key: @provider.provider_key, page: 2, format: :xml }
        assert_response :success
        doc = Nokogiri::XML::Document.parse(@response.body)
        assert_equal 1, doc.xpath('/files/*').size
      end

      test 'index with explicit per_page parameter' do
        11.times { create_file  }

        common = { provider_key: @provider.provider_key, format: :xml }
        get admin_api_cms_files_path, params: common.merge(per_page: 5)
        assert_response :success
        doc = Nokogiri::XML::Document.parse(@response.body)

        assert_equal '5', doc.xpath('/files/@per_page').text
        assert_equal '11', doc.xpath('/files/@total_entries').text
        assert_equal '3', doc.xpath('/files/@total_pages').text
        assert_equal '1', doc.xpath('/files/@current_page').text
      end

      test 'show file' do
        file = create_file
        get admin_api_cms_file_path(file), params: { provider_key: @provider.provider_key, format: :xml }
        assert_response :success

        doc = Nokogiri::XML::Document.parse(@response.body)

        assert_equal file.id.to_s, doc.xpath('/file/id').text
        assert_equal file.created_at.xmlschema, doc.xpath('/file/created_at').text
        assert_equal file.updated_at.xmlschema, doc.xpath('/file/updated_at').text
        assert_equal file.path, doc.xpath('/file/path').text
        assert_equal file.title, doc.xpath('/file/title').text
      end

      test 'update' do
        file = create_file

        put admin_api_cms_file_path(file, format: :xml), params: { provider_key: @provider.provider_key, attachment: attachment_for_upload }

        file.reload

        assert_equal 'wide.jpg', file.title
        assert_response :success
      end

      test 'create' do
        post admin_api_cms_files_path, params: { provider_key: @provider.provider_key, format: :xml, path: "/foo.bar", attachment: attachment_for_upload, section_id: @provider.sections.root.id }
        assert_response :success

        doc = Nokogiri::XML(@response.body)
        id = doc.xpath('//id').text
        file = @provider.files.find(id.to_i)
        assert_equal 'wide.jpg', file.title
      end

      test 'create with errors' do
        post admin_api_cms_files_path(format: :xml), params: { provider_key: @provider.provider_key, downloadable: true }

        assert_response :unprocessable_entity

        assert_xml_error response.body, "Path can't be blank"
      end

      test 'create without section will put the file in root section' do
        post admin_api_cms_files_path(format: :json), params: { provider_key: @provider.provider_key, path: "/foo.script", attachment: attachment_for_upload }
        assert_response :success

        assert_equal @provider.sections.root.id, JSON.parse(response.body)['file']['section_id']
      end

      test 'delete' do
        file = create_file
        delete admin_api_cms_file_path(file), params: { provider_key: @provider.provider_key, format: :xml }
        assert_nil CMS::File.find_by(id: file.id)
      end

    end
  end
end
