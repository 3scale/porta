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
        assert_equal true,  @page.published.include?('{{ part.link }}')
        assert_equal false, @page.published.include?('{{ part.url }}')

        execute_rake_task 'cms/cms.rake', 'cms:fix:pagination_href'

        @page.reload

        assert_equal true,  @page.published.include?('{{ part.url }}')
        assert_equal false, @page.published.include?('{{ part.link }}')
      end
    end

    class CmsTestFixSectionEmptyTitles < CmsTest
      def setup
        @provider = FactoryBot.create(:provider_account)
      end

      def test_fix_section_empty_titles_title_nil
        section = FactoryBot.build(:cms_section, partial_path: '/', parent: @provider.sections.root, title: nil)
        section.save!(validate: false)

        execute_rake_task 'cms/cms.rake', 'cms:fix:section_empty_titles'

        section.reload
        assert_equal section.system_name, section.title
      end

      def test_fix_section_empty_titles_title_empty
        section = FactoryBot.build(:cms_section, partial_path: '/', parent: @provider.sections.root, title: '')
        section.save!(validate: false)

        execute_rake_task 'cms/cms.rake', 'cms:fix:section_empty_titles'

        section.reload
        assert_equal section.system_name, section.title
      end

      def test_fix_section_empty_titles_system_name_nil
        section = FactoryBot.build(:cms_section, partial_path: '/', parent: @provider.sections.root, title: nil, system_name: nil)
        section.save!(validate: false)
        expected_title = "Section #{section.id}"

        execute_rake_task 'cms/cms.rake', 'cms:fix:section_empty_titles'

        section.reload
        assert_equal expected_title, section.title
      end

      def test_fix_section_empty_titles_system_name_empty
        section = FactoryBot.build(:cms_section, partial_path: '/', parent: @provider.sections.root, title: nil, system_name: '')
        section.save!(validate: false)
        expected_title = "Section #{section.id}"

        execute_rake_task 'cms/cms.rake', 'cms:fix:section_empty_titles'

        section.reload
        assert_equal expected_title, section.title
      end

      def test_fix_section_empty_titles_valid
        section = FactoryBot.create(:cms_section, partial_path: '/', parent: @provider.sections.root)

        execute_rake_task 'cms/cms.rake', 'cms:fix:section_empty_titles'

        section.reload
        assert_not_equal section.system_name, section.title
      end
    end
  end
end
