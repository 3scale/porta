# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::CMS::GroupsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)
    @provider.settings.allow_groups!
    @section = FactoryBot.create(:cms_section, parent: @provider.sections.first, provider: @provider, public: false)
    login_provider @provider
  end

  test '#create saves allowed sections' do
    group_attrs = { name: 'My Group', section_ids: ['', @section.id] }
    post provider_admin_cms_groups_path, params: { cms_group: group_attrs }

    g = @provider.provided_groups.last
    assert_equal @section, g.sections.last
  end

  test '#update allowed sections' do
    group = @provider.provided_groups.create(name: 'Group')
    group.sections << @section
    assert_equal ['Group'], @provider.provided_groups.pluck(:name)
    assert_equal [@section.id], group.sections.pluck(:id)

    another_section = FactoryBot.create(:cms_section, parent: @provider.sections.first, provider: @provider, public: false)

    put provider_admin_cms_group_path(group), params: { cms_group: { name: 'New Name', section_ids: ['', another_section.id] } }

    assert_equal ['New Name'], @provider.provided_groups.pluck(:name)
    assert_equal [another_section.id], group.sections.pluck(:id)
  end

  test '#update when no sections selected' do
    group = @provider.provided_groups.create(name: 'Group')
    group.sections << @section
    assert_equal ['Group'], @provider.provided_groups.pluck(:name)
    assert_equal [@section.id], group.sections.pluck(:id)

    put provider_admin_cms_group_path(group), params: { cms_group: { name: 'Group', section_ids: [''] } }

    assert_empty group.sections.to_a
  end

  test '#update allowed sections with invalid IDs' do
    group = @provider.provided_groups.create(name: 'Group')
    group.sections << @section
    assert_equal ['Group'], @provider.provided_groups.pluck(:name)
    assert_equal [@section.id], group.sections.pluck(:id)

    invalid_section_id = CMS::Section.maximum(:id) + 1

    assert_no_change of: -> { group.reload.sections.pluck(:id) } do
      put provider_admin_cms_group_path(group), params: { cms_group: { name: 'New Name', section_ids: ['', invalid_section_id] } }
    end

    assert_response :not_found
  end

  test "#update group with another provider's section" do
    group = @provider.provided_groups.create(name: 'Group')
    assert_empty group.sections

    another_provider = FactoryBot.create(:provider_account)
    another_provider.settings.allow_groups!
    another_section = FactoryBot.create(:cms_section, parent: another_provider.sections.first, provider: another_provider, public: false)

    assert_no_difference group.sections.method(:count) do
      put provider_admin_cms_group_path(group), params: { cms_group: { section_ids: ['', @section.id, another_section.id] } }
    end

    assert_response :not_found
  end
end
