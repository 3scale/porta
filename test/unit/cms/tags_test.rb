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
    first_provider = FactoryBot.create(:provider_account)
    first_page     = FactoryBot.create(:cms_page, provider: first_provider)
    first_admin    = FactoryBot.create(:simple_admin, account: first_provider, tenant_id: first_provider.id)

    second_provider = FactoryBot.create(:provider_account)
    second_page     = FactoryBot.create(:cms_page, provider: second_provider)
    second_admin    = FactoryBot.create(:simple_admin, account: second_provider, tenant_id: second_provider.id)

    User.current = first_admin
    first_page.update_attribute(:tag_list, 'awesome, apis')
    assert_equal 2, ActsAsTaggableOn::Tag.count

    User.current = second_admin
    second_page.update_attribute(:tag_list, 'awesome, stuff')
    assert_equal 2, ActsAsTaggableOn::Tag.count

    assert_equal 4, ActsAsTaggableOn::Tag.unscoped.count
  end

  %i[cms_page cms_file].each do |factory|
    test "#{factory} tags persist, serialize and remain isolated between providers" do
      first_provider = FactoryBot.create(:provider_account)
      second_provider = FactoryBot.create(:provider_account)
      first_admin = FactoryBot.create(:simple_admin, account: first_provider, tenant_id: first_provider.id)
      second_admin = FactoryBot.create(:simple_admin, account: second_provider, tenant_id: second_provider.id)
      first_record = FactoryBot.create(factory, provider: first_provider)
      second_record = FactoryBot.create(factory, provider: second_provider)

      User.current = first_admin
      first_record.update!(tag_list: 'shared, old')
      assert_same_elements %w[shared old], first_record.reload.tag_list
      assert_not first_record.as_json.key?('tag_list')

      User.current = second_admin
      second_record.update!(tag_list: 'shared, other')
      assert_same_elements %w[shared other], second_record.reload.tag_list
      assert_equal [second_record.id], second_record.class.where(provider_id: second_provider.id).tagged_with('shared').pluck(:id)

      User.current = first_admin
      first_record.update!(tag_list: 'shared, new')
      assert_same_elements %w[shared new], first_record.reload.tag_list
      assert_not first_record.as_json.key?('tag_list')
      assert_equal [first_record.id], first_record.class.where(provider_id: first_provider.id).tagged_with('shared').pluck(:id)

      User.current = second_admin
      assert_same_elements %w[shared other], second_record.reload.tag_list
    end
  end
end
