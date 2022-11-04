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
end

