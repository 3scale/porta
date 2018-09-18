require 'test_helper'

class CMS::Builtin::PageTest < ActiveSupport::TestCase

  def setup
    @provider = Factory(:simple_provider)
    @root_sec = Factory(:root_cms_section, provider: @provider)
  end


  test 'cannot be deleted' do
    page = Factory.build(:cms_builtin_page, provider: @provider)

    assert_equal false, page.respond_to?(:destroy)
    assert_raises(NoMethodError) { page.destroy }
  end

  test 'can be reset' do
    page = Factory.build(:cms_builtin_page,
                          provider: @provider,
                          section: @root_sec,
                          # has to be a known system_name
                          system_name: 'applications/new')
    page.draft = 'BEFORE'
    page.save!
    assert_equal page.draft, 'BEFORE'

    page.reset!

    assert_match /{%\s*form\s*'application.create'.*%}/, page.draft
  end

  test 'always has liquid enabled' do
    # attribute ignored
    page = Factory.build(:cms_builtin_page, provider: @provider, liquid_enabled: false)
    assert page.liquid_enabled?, 'liquid processing disabled for builtin page'

    # true even if the DB column is set
    page.save!
    page.update_column(:liquid_enabled, false)
    assert page.liquid_enabled?, 'liquid processing disabled for builtin page'
  end

  test 'content_type is text/html' do
    page = Factory.build(:cms_builtin_page, provider: @provider)
    assert_equal 'text/html', page.content_type
  end

end
