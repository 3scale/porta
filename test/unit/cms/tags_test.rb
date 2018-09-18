require 'test_helper'

class CMS::TagsTest < ActiveSupport::TestCase
  def setup
    User.current = nil
  end

  def teardown
    User.current = nil
  end

  # this test relies on properly set tenant_id by triggers
  def test_tags_are_tenant_scoped
    first_provider = FactoryGirl.create(:provider_account)
    first_page     = FactoryGirl.create(:cms_page, provider: first_provider)
    first_admin    = FactoryGirl.create(:simple_admin, account: first_provider, tenant_id: first_provider.id)

    second_provider = FactoryGirl.create(:provider_account)
    second_page     = FactoryGirl.create(:cms_page, provider: second_provider)
    second_admin    = FactoryGirl.create(:simple_admin, account: second_provider, tenant_id: second_provider.id)

    User.current = first_admin
    first_page.update_attribute(:tag_list, 'awesome, apis')
    assert_equal 2, ActsAsTaggableOn::Tag.count

    User.current = second_admin
    second_page.update_attribute(:tag_list, 'awesome, stuff')
    assert_equal 2, ActsAsTaggableOn::Tag.count

    assert_equal 4, ActsAsTaggableOn::Tag.unscoped.count
  end
end
