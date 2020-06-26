require 'test_helper'

class ApiDocs::AccountDataTest < ActiveSupport::TestCase

  SORT_PROC = ->(result) { result[:name] }

  def setup
    @account = FactoryBot.create(:account, org_name: 'mycompany')

    @provider = FactoryBot.create(:simple_provider)
    @buyer = FactoryBot.create(:simple_buyer, provider_account: @provider)

    @services = [
        service1 = FactoryBot.create(:simple_service, name: 'service-user-key', backend_version: 1, account_id: @provider.id),
        service2 = FactoryBot.create(:simple_service, name: 'service-app-key', backend_version: 2, account_id: @provider.id),
        service3 = FactoryBot.create(:simple_service, name: 'service-oauth', backend_version: 'oauth', account_id: @provider.id),
    ]

    plan1 = FactoryBot.create(:simple_application_plan, issuer: service1)
    plan2 = FactoryBot.create(:simple_application_plan, issuer: service2)
    plan3 = FactoryBot.create(:simple_application_plan, issuer: service3)

    apps = [
      bought_app1 = FactoryBot.create(:simple_cinstance, service: service1, application_id: 'APP1_ID', name: 'User key app', plan: plan1, user_account: @buyer, user_key: 'secret-key'),
      bought_app2 = FactoryBot.create(:simple_cinstance, service: service2, application_id: 'APP2_ID', name: 'App key app', plan: plan2, user_account: @buyer),
      bought_app3 = FactoryBot.create(:simple_cinstance, service: service3, application_id: 'APP3_ID', name: 'OAuth app', plan: plan3, user_account: @buyer)
    ]

    bought_app2.application_keys.add('app-secret-key').save!
    bought_app3.application_keys.update_all(value: 'oauth-secret-key')
  end

  def test_status_with_account
    data = ApiDocs::BuyerData.new(@buyer).as_json
    assert_equal 200, data[:status]
  end

  def test_status_without_user
    data = ApiDocs::ProviderData.new(nil).as_json
    assert_equal 401, data[:status]
  end

  def test_returns_metrics_for_provider
    @services.each { |s| s.metrics.delete_all }
    metric = FactoryBot.create(:metric, service: @services[0], friendly_name: 'top level metric', unit: '1 per day', system_name: 'foo_metric')
    data = ApiDocs::ProviderData.new(@provider).as_json[:results]
    assert_equal [{name: 'top level metric | service-user-key', value: 'foo_metric'}], data[:metric_names]
    assert_equal [{name: 'top level metric | service-user-key', value: metric.id}], data[:metric_ids]
  end

  def test_returns_user_ids_for_provider
    data = ApiDocs::ProviderData.new(@provider).as_json[:results]
    assert_equal [], data[:user_ids]
  end

  def test_returns_admin_ids_for_provider
    data = ApiDocs::ProviderData.new(@account).as_json[:results]
    values = @account.admin_user_ids.map do |admin_id|
      {name: 'mycompany', value: admin_id}
    end
    assert_equal values, data[:admin_ids]
  end

  def test_returns_provided_applications_for_provider
    data = ApiDocs::ProviderData.new(@provider).as_json[:results]
    assert_equal [{name: 'User key app - service-user-key', value: 'secret-key'}], data[:user_keys]
    assert_equal [{name: 'OAuth app - service-oauth', value: 'APP3_ID'}], data[:client_ids]
    assert_equal [{name: 'OAuth app - service-oauth', value: 'oauth-secret-key'}], data[:client_secrets]
  end

  def test_returns_bought_applications_for_buyer
    data = ApiDocs::BuyerData.new(@buyer).as_json[:results]
    assert_equal [{name: 'User key app - service-user-key', value: 'secret-key'}], data[:user_keys]
    assert_equal [{name: 'App key app - service-app-key', value: 'APP2_ID'}, { name: 'OAuth app - service-oauth', value: 'APP3_ID'}], data[:app_ids].sort_by(&SORT_PROC)
    assert_equal [{name: 'App key app - service-app-key', value: 'app-secret-key'}, { name: 'OAuth app - service-oauth', value: 'oauth-secret-key'}], data[:app_keys].sort_by(&SORT_PROC)
    assert_equal [{name: 'OAuth app - service-oauth', value: 'APP3_ID'}], data[:client_ids]
    assert_equal [{name: 'OAuth app - service-oauth', value: 'oauth-secret-key'}], data[:client_secrets]
  end

  def test_for_app_with_backend_version
    data = ApiDocs::BuyerData.new(@buyer).as_json[:results]
    assert_equal [{name: 'User key app - service-user-key', value: 'secret-key'}], data[:user_keys]
    assert_equal [{name: 'App key app - service-app-key', value: 'app-secret-key'}, { name: 'OAuth app - service-oauth', value: 'oauth-secret-key'}], data[:app_keys].sort_by(&SORT_PROC)
    assert_equal [{name: 'OAuth app - service-oauth', value: 'APP3_ID'}], data[:client_ids]
    assert_equal [{name: 'OAuth app - service-oauth', value: 'oauth-secret-key'}], data[:client_secrets]
  end

  def test_returns_correct_data_for_buyer
    instance = ApiDocs::BuyerData.new(@buyer)
    data = instance.as_json[:results]
    keys = instance.data_items

    keys.each do |key|
      assert data.has_key?(key.to_sym)
    end
  end

  def test_returns_correct_data_for_provider
    instance = ApiDocs::ProviderData.new(@provider)
    data = instance.as_json[:results]
    keys = instance.data_items

    keys.each do |key|
      assert data.has_key?(key.to_sym)
    end
  end

end
