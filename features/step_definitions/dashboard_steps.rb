# frozen_string_literal: true

def service_id_for_name(name)
  page.find_by!(id: 'apis').find('section', text: /#{name}/i)[:id][/\d+/]
end

def service_for_name(name)
  service_id = service_id_for_name(name)
  page.find("#service_#{service_id}")
end

def hits_for_name(name, opts = {})
  service_id = service_id_for_name(name)
  page.find_by!({ id: "dashboard-widget-service_id-#{service_id}service_hits" }, opts)
end

def top_traffic_for_name(name, opts = {})
  service_id = service_id_for_name(name)
  page.find_by!({ id: "dashboard-widget-service_id-#{service_id}service_top_traffic" }, opts)
end

Then "I should not see {string} overview data" do |service_name|
  hits = hits_for_name(service_name, visible: false)
  top_traffic = top_traffic_for_name(service_name, visible: false)

  assert_not hits.visible?
  assert_not top_traffic.visible?
end

When "overview data of {string} is displayed" do |service_name|
  hits = hits_for_name(service_name)
  top_traffic = top_traffic_for_name(service_name)

  assert hits.has_css? '.Dashboard-chart'
  assert top_traffic.has_css? '.Dashboard-chart'
end

When 'All Dashboard widgets are loaded' do
  DashboardWidgetPresenter.any_instance.stubs(:loaded?).returns(true)
end
