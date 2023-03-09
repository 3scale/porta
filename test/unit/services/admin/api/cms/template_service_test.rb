# frozen_string_literal: true

require 'test_helper'

class TemplateServiceTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create :provider_account
  end

  class TemplatesPageTest < TemplateServiceTest
    def setup
      super
      @section = FactoryBot.create :cms_section, provider: @provider, parent: @provider.sections.root
      @layout = FactoryBot.create :cms_layout, provider: @provider
    end

    class CreateTest < TemplatesPageTest
      test 'section is set to root when no section provided' do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api'
        }
        params = permitted_params.merge({
                                          'type' => 'page'
                                        })

        template = Admin::Api::CMS::TemplateService::Create.call(@provider, params, permitted_params)

        assert_equal @provider.sections.root, template.section
      end

      test 'section is set to the given section by ID' do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api',
          'section_id' => @section.id
        }
        params = permitted_params.merge({
                                          'type' => 'page'
                                        })

        template = Admin::Api::CMS::TemplateService::Create.call(@provider, params, permitted_params)

        assert_equal @section, template.section
      end

      test 'section is set to the given section by system name' do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api'
        }
        params = permitted_params.merge({
                                          'type' => 'page',
                                          'section_name' => @section.system_name
                                        })

        template = Admin::Api::CMS::TemplateService::Create.call(@provider, params, permitted_params)

        assert_equal @section, template.section
      end

      test "UnknownSectionError is raised when the given section ID doesn't exist" do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api',
          'section_id' => 100
        }
        params = permitted_params.merge({
                                          'type' => 'page'
                                        })

        assert_raises (Admin::Api::CMS::TemplateService::UnknownSectionError) do
          Admin::Api::CMS::TemplateService::Create.call(@provider, params, permitted_params)
        end
      end

      test "UnknownSectionError is raised when the given section name doesn't exist" do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api'
        }
        params = permitted_params.merge({
                                          'type' => 'page',
                                          'section_name' => 'non-existent'
                                        })

        assert_raises (Admin::Api::CMS::TemplateService::UnknownSectionError) do
          Admin::Api::CMS::TemplateService::Create.call(@provider, params, permitted_params)
        end
      end

      test 'layout is not set when no layout provided' do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api'
        }
        params = permitted_params.merge({
                                          'type' => 'page'
                                        })

        template = Admin::Api::CMS::TemplateService::Create.call(@provider, params, permitted_params)

        assert_nil template.layout
      end

      test 'layout is set to the given layout by ID' do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api',
          'layout_id' => @layout.id
        }
        params = permitted_params.merge({
                                          'type' => 'page'
                                        })

        template = Admin::Api::CMS::TemplateService::Create.call(@provider, params, permitted_params)

        assert_equal @layout, template.layout
      end

      test 'layout is set to the given layout by system name' do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api'
        }
        params = permitted_params.merge({
                                          'type' => 'page',
                                          'layout_name' => @layout.system_name
                                        })

        template = Admin::Api::CMS::TemplateService::Create.call(@provider, params, permitted_params)

        assert_equal @layout, template.layout
      end

      test "UnknownLayoutError is raised when the given layout ID doesn't exist" do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api',
          'layout_id' => 100
        }
        params = permitted_params.merge({
                                          'type' => 'page'
                                        })

        assert_raises (Admin::Api::CMS::TemplateService::UnknownLayoutError) do
          Admin::Api::CMS::TemplateService::Create.call(@provider, params, permitted_params)
        end
      end

      test "UnknownLayoutError is raised when the given layout name doesn't exist" do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api'
        }
        params = permitted_params.merge({
                                          'type' => 'page',
                                          'layout_name' => 'non-existent'
                                        })

        assert_raises (Admin::Api::CMS::TemplateService::UnknownLayoutError) do
          Admin::Api::CMS::TemplateService::Create.call(@provider, params, permitted_params)
        end
      end
    end

    class UpdateTest < TemplatesPageTest
      def setup
        super
        @template = FactoryBot.create :cms_page, provider: @provider, section: @section, layout: @layout
        @section2 = FactoryBot.create :cms_section, provider: @provider, parent: @provider.sections.root
        @layout2 = FactoryBot.create :cms_layout, provider: @provider
      end

      test 'section remains unchanged when no section provided' do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api'
        }
        params = permitted_params

        Admin::Api::CMS::TemplateService::Update.call(@provider, params, permitted_params, @template)

        assert_equal @section, @template.reload.section
      end

      test 'section is set to the given section by ID' do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api',
          'section_id' => @section2.id
        }
        params = permitted_params

        Admin::Api::CMS::TemplateService::Update.call(@provider, params, permitted_params, @template)

        assert_equal @section2, @template.reload.section
      end

      test 'section is set to the given section by system name' do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api'
        }
        params = permitted_params.merge({
                                          'section_name' => @section2.system_name
                                        })

        Admin::Api::CMS::TemplateService::Update.call(@provider, params, permitted_params, @template)

        assert_equal @section2, @template.reload.section
      end

      test "UnknownSectionError is raised when the given section ID doesn't exist" do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api',
          'section_id' => 100
        }
        params = permitted_params

        assert_raises (Admin::Api::CMS::TemplateService::UnknownSectionError) do
          Admin::Api::CMS::TemplateService::Update.call(@provider, params, permitted_params, @template)
        end
      end

      test "UnknownSectionError is raised when the given section name doesn't exist" do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api'
        }
        params = permitted_params.merge({
                                          'section_name' => 'non-existent'
                                        })

        assert_raises (Admin::Api::CMS::TemplateService::UnknownSectionError) do
          Admin::Api::CMS::TemplateService::Update.call(@provider, params, permitted_params, @template)
        end
      end

      test 'layout remains unchanged when no layout provided' do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api'
        }
        params = permitted_params

        Admin::Api::CMS::TemplateService::Update.call(@provider, params, permitted_params, @template)

        assert_equal @layout, @template.reload.layout
      end

      test 'layout is removed when received as an empty ID' do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api',
          'layout_id' => ''
        }
        params = permitted_params

        Admin::Api::CMS::TemplateService::Update.call(@provider, params, permitted_params, @template)

        assert_nil @template.reload.layout
      end

      test 'layout is removed when received as an empty system name' do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api'
        }
        params = permitted_params.merge({
                                          'layout_name' => ''
                                        })

        Admin::Api::CMS::TemplateService::Update.call(@provider, params, permitted_params, @template)

        assert_nil @template.reload.layout
      end

      test 'layout is set to the given layout by ID' do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api',
          'layout_id' => @layout2.id
        }
        params = permitted_params

        Admin::Api::CMS::TemplateService::Update.call(@provider, params, permitted_params, @template)

        assert_equal @layout2, @template.reload.layout
      end

      test 'layout is set to the given layout by system_name' do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api'
        }
        params = permitted_params.merge({
                                          'layout_name' => @layout2.system_name
                                        })

        Admin::Api::CMS::TemplateService::Update.call(@provider, params, permitted_params, @template)

        assert_equal @layout2, @template.reload.layout
      end

      test "UnknownLayoutError is raised when the given layout ID doesn't exist" do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api',
          'layout_id' => 100
        }
        params = permitted_params

        assert_raises (Admin::Api::CMS::TemplateService::UnknownLayoutError) {
          Admin::Api::CMS::TemplateService::Update.call(@provider, params, permitted_params, @template)
        }
      end

      test "UnknownLayoutError is raised when the given layout name doesn't exist" do
        permitted_params = {
          'title' => 'test API',
          'path' => '/testAPI',
          'system_name' => 'test_api'
        }
        params = permitted_params.merge({
                                          'layout_name' => 'non-existent'
                                        })

        assert_raises (Admin::Api::CMS::TemplateService::UnknownLayoutError) {
          Admin::Api::CMS::TemplateService::Update.call(@provider, params, permitted_params, @template)
        }
      end
    end
  end
end
