require 'test_helper'

class Tasks::Cms::CmsTest < ActiveSupport::TestCase

  def setup
    @page = FactoryGirl.build(:cms_partial, system_name: 'shared/pagination',
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
