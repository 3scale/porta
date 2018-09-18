require 'test_helper'

class CMS::TemplateTest < ActiveSupport::TestCase

  def test_tenant_id
    template = FactoryGirl.create(:cms_template)
    template.reload
    assert_not_nil template.tenant_id
    assert_equal template.provider.id, template.tenant_id
  end

  def test_mime_type
    template = FactoryGirl.build_stubbed(:cms_template, content_type: nil)

    refute template.mime_type

    template.content_type = 'text/html'

    assert template.mime_type
  end

  test '#but scope' do
    page = Factory(:cms_page, draft: 'something to publish')
    page = Factory(:cms_page, draft: 'something to publish')
    page = Factory(:cms_page, draft: 'something to publish')
    page = Factory(:cms_email_template, draft: 'something to publish')
    assert_equal 1, CMS::Template.but(CMS::Page).count
  end

  test '#but scope with many butts' do
    page = Factory(:cms_page, draft: 'something to publish')
    page = Factory(:cms_page, draft: 'something to publish')
    page = Factory(:cms_email_template, draft: 'something to publish')
    page = Factory(:cms_layout, draft: 'something to publish')

    assert_equal 2, CMS::Template.but(CMS::Layout, "CMS::EmailTemplate").count
  end

  test 'publish' do
    page = Factory(:cms_page, draft: 'something to publish')
    assert_equal nil, page.content
    page.publish!
    assert_equal page.content, 'something to publish'
    assert_equal 2, page.versions.count
  end

  test 'revert' do
    page = Factory(:cms_page, draft: 'new', published: 'old')
    assert_equal 'new', page.current
    page.revert!
    assert_equal 'old', page.current
  end

  test '#upgrade_content' do
    page = Factory(:cms_page, draft: 'old draft', published: 'published')

    page.upgrade_content!('NEW THING')

    # Should create a version of the original file and the current file
    assert_equal 2, page.versions.count
    assert_equal '[3scale System]', page.versions.first.updated_by
    assert_equal 'old draft', page.draft
    assert_equal 'NEW THING', page.published
  end

  test 'liquid syntax validation' do
    page = Factory.build(:cms_page, draft: '{% invalid liquid %}', published: '{{ valid.one }}', liquid_enabled: false)

    assert page.valid?

    page.liquid_enabled = true

    assert page.invalid?
    assert page.errors[:draft].present?
    assert page.errors[:published].blank?

    page.published, page.draft = page.draft, page.published

    # we don't validate published, just draft
    assert page.valid?
  end

end
