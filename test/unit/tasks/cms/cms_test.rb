require 'test_helper'

module Tasks
  class CmsTest < ActiveSupport::TestCase

    def setup
      @page = FactoryBot.build(:cms_partial, system_name: 'shared/pagination',
        published: '<p>Title</p><a href="{{ part.link }}">Supertramp</a>')

      @page.save(validate: false)
    end

    def test_fix_pagination_href
      assert_equal true,  @page.published.include?('{{ part.link }}')
      assert_equal false, @page.published.include?('{{ part.url }}')

      execute_rake_task 'cms/cms.rake', 'cms:fix:pagination_href'

      @page.reload

      assert_equal true,  @page.published.include?('{{ part.url }}')
      assert_equal false, @page.published.include?('{{ part.link }}')
    end
  end

  class FixInvalidSysNameSections < ActiveSupport::TestCase
    def setup
      @provider = FactoryBot.create(:provider_account)
    end

    test 'fixes invalid system names' do
      section = FactoryBot.build(:cms_section, partial_path: '/', parent: @provider.sections.root, title: 'New section',
                                 system_name: 'invalid name')
      section.save(validate: false)
      expected_sysname = "section-#{section.id}"

      execute_rake_task 'cms/cms.rake', 'cms:fix:section_invalid_system_names'

      assert_equal expected_sysname, section.reload.system_name
    end

    test "doesn't change valid system names" do
      expected_sysname = 'new-section'
      section = FactoryBot.create(:cms_section, partial_path: '/', parent: @provider.sections.root, title: 'New section',
                                 system_name: expected_sysname)

      execute_rake_task 'cms/cms.rake', 'cms:fix:section_invalid_system_names'

      assert_equal expected_sysname, section.reload.system_name
    end
  end
end
