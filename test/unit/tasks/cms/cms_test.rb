require 'test_helper'

module Tasks
  class CmsTest < ActiveSupport::TestCase
    class CmsTestFixPaginationHref < CmsTest
      def setup
        @page = FactoryBot.build(:cms_partial, system_name: 'shared/pagination',
                                 published: '<p>Title</p><a href="{{ part.link }}">Supertramp</a>')

        @page.save(validate: false)
      end

      def test_fix_pagination_href
        assert_includes @page.published, '{{ part.link }}'
        assert_not_includes @page.published, '{{ part.url }}'

        execute_rake_task 'cms/cms.rake', 'cms:fix:pagination_href'

        @page.reload

        assert_includes @page.published, '{{ part.url }}'
        assert_not_includes @page.published, '{{ part.link }}'
      end
    end

    class CmsTestFixSectionEmptyTitles < CmsTest
      def setup
        @provider = FactoryBot.create(:provider_account)
      end

      [nil, ""].each do |empty_val|
        test "section titles are fixed for #{empty_val.inspect}" do
          section = FactoryBot.build(:cms_section, partial_path: '/', parent: @provider.sections.root, title: empty_val, system_name: 'system-name')
          section.save!(validate: false)
          expected_title = section.system_name

          execute_rake_task 'cms/cms.rake', 'cms:fix:section_empty_titles'

          section.reload
          assert_equal expected_title, section.title
        end
      end

      def test_fix_section_empty_titles_valid_dont_change
        title = 'valid_title'
        sysname = 'valid_system-name'
        section = FactoryBot.create(:cms_section, partial_path: '/', parent: @provider.sections.root, title: title, system_name: sysname)

        execute_rake_task 'cms/cms.rake', 'cms:fix:section_empty_titles'

        section.reload
        assert_equal title, section.title
        assert_equal sysname, section.system_name
      end
    end
  end
end
