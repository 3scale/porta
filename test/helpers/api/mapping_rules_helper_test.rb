require 'test_helper'

class Api::MappingRulesHelperTest < ActionView::TestCase
  def setup
    @provider = FactoryBot.build(:provider_account)
    @service  = FactoryBot.build_stubbed(:simple_service)
  end

  test 'links to the independent mapping rules page if enabled' do
    @provider.stubs(:independent_mapping_rules_enabled?).returns(true)
    link = link_to_mapping_rules(service: @service)
    expected_path = admin_service_proxy_rules_path(@service)
    assert_match(/#{expected_path}/, link)
  end

  test 'links to the mapping rules in the integration page if independent mapping rules is disabled' do
    @provider.stubs(:independent_mapping_rules_enabled?).returns(false)
    link = link_to_mapping_rules(service: @service)
    expected_path = edit_admin_service_integration_path(@service, anchor: 'mapping-rules')
    assert_match(/#{expected_path}/, link)
    assert_match(/data-behavior="open-mapping-rules"/, link)
  end

  private

  def current_account
    @provider
  end
end
