# frozen_string_literal: true

def service_id_for_name(name)
  page.find_by_id('apis').find('section', text: /#{name}/i)[:id][/\d+/]
end

def service_for_name(name)
  service_id = service_id_for_name(name)
  page.find("#service_#{service_id}")
end

def hits_for_name(name, opts = {})
  service_id = service_id_for_name(name)
  page.find_by_id("dashboard-widget-service_id-#{service_id}service_hits", opts)
end

def top_traffic_for_name(name, opts = {})
  service_id = service_id_for_name(name)
  page.find_by_id("dashboard-widget-service_id-#{service_id}service_top_traffic", opts)
end

When 'All Dashboard widgets are loaded' do
  DashboardWidgetPresenter.any_instance.stubs(:loaded?).returns(true)
end

Given "{int} products and {int} backend apis" do |products, backends|
  FactoryBot.create_list(:service, products, account: @provider)
  FactoryBot.create_list(:backend_api, backends, account: @provider)

  visit admin_dashboard_path
end

Then "the most recently updated products and backends can be found in the dashboard" do
  assert_equal current_path, provider_admin_dashboard_path
  products = @provider.services.order(updated_at: :desc)
  backend_apis = @provider.backend_apis.order(updated_at: :desc)

  within selector_for('the products widget') do
    products.first(5).each do |p|
      assert_selector('.pf-c-data-list__item', text: p.name)
    end
    assert_no_selector('.pf-c-data-list__item', text: products.last.name)
  end

  within selector_for('the backends widget') do
    backend_apis.first(5).each do |b|
      assert_selector('.pf-c-data-list__item', text: b.name)
    end
    assert_no_selector('.pf-c-data-list__item', text: backend_apis.last.name)
  end
end
