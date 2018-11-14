require 'test_helper'

class Liquid::Drops::ProviderDropTest < ActiveSupport::TestCase
  include Liquid

  def setup
    @provider = Factory(:provider_account)
    @drop = Drops::Provider.new(@provider)
  end

  test 'support emails' do
    assert_equal @drop.support_email, @provider.support_email
    assert_equal @drop.finance_support_email, @provider.finance_support_email
  end

  test 'supports full_address' do
    assert_equal @drop.full_address, @provider.full_address
  end

  test "#services" do
    Factory  :service, account: @provider
    assert_equal 2, @drop.services.size
  end

  test "multiple_users_allowed?" do
    @provider.settings.update_attribute(:multiple_users_switch, 'visible')
    assert_equal true, @drop.multiple_users_allowed?

    @provider.settings.update_attribute(:multiple_users_switch, 'denied')
    assert_equal false, @drop.multiple_users_allowed?
  end

  test 'multiple_applications_allowed?' do
    @provider.settings.update_attribute(:multiple_applications_switch, 'visible')
    assert_equal true, @drop.multiple_applications_allowed?

    @provider.settings.update_attribute(:multiple_applications_switch, 'denied')
    assert_equal false, @drop.multiple_applications_allowed?
  end


  # Provider drop should return multiservice_allowed true only when service has a plan and it is published
  # https://github.com/3scale/system/pull/3275
  test 'multiple_services_allowed?' do
    Account.any_instance.stubs(multiservice?: false, has_visible_services_with_plans?: false)
    refute @drop.multiple_services_allowed?

    Account.any_instance.stubs(multiservice?: true, has_visible_services_with_plans?: false)
    refute @drop.multiple_services_allowed?

    Account.any_instance.stubs(multiservice?: false, has_visible_services_with_plans?: true)
    refute @drop.multiple_services_allowed?

    Account.any_instance.stubs(multiservice?: true, has_visible_services_with_plans?: true)
    assert @drop.multiple_services_allowed?
  end

  test 'api_specs' do
    valid_attributes = {name: 'name', body: '{"apis": [], "basePath": "http://example.com"}'}
    services = FactoryGirl.create_list(:service, 2, account: @provider)
    @provider.api_docs_services.create!(valid_attributes.merge({name: 'accessible'})) # accessible without service
    services.first.api_docs_services.create!(valid_attributes.merge({name: 'service-accessible'})) # accessible with service
    services.last.api_docs_services.create!(valid_attributes.merge({name: 'service-deleted'})) # non-accessible with service
    services.last.mark_as_deleted!

    api_specs_collection_drop = @drop.api_specs
    assert_equal 2, api_specs_collection_drop.length
    api_specs_collection_drop.each do |api_spec_drop|
      assert_instance_of Liquid::Drops::ApiSpec, api_spec_drop
      assert_includes %w[accessible service_accessible], api_spec_drop.system_name
    end
  end

end
