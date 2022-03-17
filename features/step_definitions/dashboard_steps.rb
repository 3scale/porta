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

Then(/^I should not see "([^"]*)" overview data$/) do |service_name|
  hits = hits_for_name(service_name, visible: false)
  top_traffic = top_traffic_for_name(service_name, visible: false)

  assert_not hits.visible?
  assert_not top_traffic.visible?
end

When(/^overview data of "([^"]*)" is displayed$/) do |service_name|
  hits = hits_for_name(service_name)
  top_traffic = top_traffic_for_name(service_name)

  assert hits.has_css? '.Dashboard-chart'
  assert top_traffic.has_css? '.Dashboard-chart'
end

When(/^I select the (products|backends) tab$/) do |tab|
  find('button', id: "tab-#{tab}").click
end

When (/^I search for "([^"]*)" using the (products|backends) search bar/) do |query, tab|
  search_bar = find("##{tab}_search").find('input[type="search"]')
  search_bar.send_keys query
end

When 'All Dashboard widgets are loaded' do
  DashboardWidgetPresenter.any_instance.stubs(:loaded?).returns(true)
end

When "an admin needs to find a product or backend quickly" do
  FactoryBot.create_list(:service, 10, account: @provider)
  FactoryBot.create_list(:backend_api, 10, account: @provider)

  visit admin_dashboard_path
end

Then "the most recently updated products and backends can be found in the dashboard" do
  assert_equal current_path, provider_admin_dashboard_path
  products = @provider.services.order(updated_at: :desc)
  backend_apis = @provider.backend_apis.order(updated_at: :desc)

  within products_widget do
    products.first(5).each do |p|
      assert_selector('.pf-c-data-list__item', text: p.name)
    end
    assert_no_selector('.pf-c-data-list__item', text: products.last.name)
  end

  within backend_apis_widget do
    backend_apis.first(5).each do |b|
      assert_selector('.pf-c-data-list__item', text: b.name)
    end
    assert_no_selector('.pf-c-data-list__item', text: backend_apis.last.name)
  end
end

When "an admin needs a new product or backend quickly" do
  visit admin_dashboard_path
end

Then "products and backends can be created from the dashboard" do
  assert_equal current_path, provider_admin_dashboard_path

  assert_selector("a[href='#{new_admin_service_path}']", text: 'Create Product')
  assert_selector("a[href='#{new_provider_admin_backend_api_path}']", text: 'Create Backend')
end

def products_widget
  find('#products-widget')
end

def backend_apis_widget
  find('#backends-widget')
end
