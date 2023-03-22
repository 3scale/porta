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
        get admin_api_cms_files_path, params: { provider_key: @provider.provider_key, format: :json }
        assert_response :success

        assert_equal 20, response.parsed_body['files'].size
      end

      test 'index with pagination' do
        21.times { create_file  }

        # first page
        get admin_api_cms_files_path, params: { provider_key: @provider.provider_key, format: :json }
        assert_response :success

        assert_equal 20, response.parsed_body['files'].size
        assert_equal(
          { per_page: 20, total_entries: 21, total_pages: 2, current_page: 1 },
          response.parsed_body['metadata'].symbolize_keys
        )

        # second page
        get admin_api_cms_files_path, params: { provider_key: @provider.provider_key, page: 2, format: :json }
        assert_response :success

        assert_equal 1, response.parsed_body['files'].size
        assert_equal(
          { per_page: 20, total_entries: 21, total_pages: 2, current_page: 2 },
          response.parsed_body['metadata'].symbolize_keys
        )
      end

      test 'index with explicit per_page parameter' do
        11.times { create_file  }

        common = { provider_key: @provider.provider_key, format: :json }
        get admin_api_cms_files_path, params: common.merge(per_page: 5)
        assert_response :success

        assert_equal 5, response.parsed_body['files'].size
        assert_equal(
          { per_page: 5, total_entries: 11, total_pages: 3, current_page: 1 },
          response.parsed_body['metadata'].symbolize_keys
        )
      end

      test 'show file' do
        file = create_file
        get admin_api_cms_file_path(file), params: { provider_key: @provider.provider_key, format: :json }
        assert_response :success

        assert_equal(
          %w[id created_at updated_at section_id path downloadable url title content_type],
          response.parsed_body['file'].keys
        )
      end

      test 'update' do
        file = create_file

        put admin_api_cms_file_path(file, format: :json), params: { provider_key: @provider.provider_key, attachment: attachment_for_upload }

        file.reload

        assert_equal 'wide.jpg', file.title
        assert_response :success
      end

      test 'create' do
        post admin_api_cms_files_path, params: { provider_key: @provider.provider_key, format: :json, path: "/foo.bar", attachment: attachment_for_upload, section_id: @provider.sections.root.id }
        assert_response :success

        id = response.parsed_body['file']['id']
        file = @provider.files.find(id.to_i)
        assert_equal 'wide.jpg', file.title
      end

      test 'create with errors' do
        post admin_api_cms_files_path(format: :json), params: { provider_key: @provider.provider_key, downloadable: true }

        assert_response :unprocessable_entity

        assert_equal(
          { path: ["can't be blank"], attachment: ["can't be blank"] },
          response.parsed_body['errors'].symbolize_keys
        )
      end

      test 'create without section will put the file in root section' do
        post admin_api_cms_files_path(format: :json), params: { provider_key: @provider.provider_key, path: "/foo.script", attachment: attachment_for_upload }
        assert_response :success

        assert_equal @provider.sections.root.id, JSON.parse(response.body)['file']['section_id']
      end

      test 'delete' do
        file = create_file
        delete admin_api_cms_file_path(file), params: { provider_key: @provider.provider_key, format: :json }
        assert_nil CMS::File.find_by(id: file.id)
      end
    end
  end
end
