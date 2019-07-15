def service_id_for_name (name)
  page.find_by_id('apis').find('section', :text => name)[:id][/\d+/]
end

def service_for_name (name)
  service_id = service_id_for_name(name)
  page.find("#service_#{service_id}")
end

def hits_for_name (name)
  service_id = service_id_for_name(name)
  page.find_by_id("dashboard-widget-service_id-#{service_id}service_hits")
end

def top_traffic_for_name (name)
  service_id = service_id_for_name(name)
  page.find_by_id("dashboard-widget-service_id-#{service_id}service_top_traffic")
end

When(/^service "([^"]*)" is (folded|unfolded)$/) do |service_name, state|
  service = service_for_name(service_name)

  assert     service[:class].include? 'is-closed' if state == 'folded'
  assert_not service[:class].include? 'is-closed' if state == 'unfolded'
end

When(/^data of "([^"]*)" is loading$/) do |service_name|
  hits = hits_for_name(service_name)
  top_traffic = top_traffic_for_name(service_name)

  assert hits.has_css? '.DashboardWidget-spinner'
  assert top_traffic.has_css? '.DashboardWidget-spinner'
end

When(/^data of "([^"]*)" should be empty$/) do |service_name|
  step %{data of "#{service_name}" is loading}
end

When(/^data of "([^"]*)" is displayed$/) do |service_name|
  hits = hits_for_name(service_name)
  top_traffic = top_traffic_for_name(service_name)

  assert_not hits.has_css? '.DashboardWidget-spinner'
  assert_not top_traffic.has_css? '.DashboardWidget-spinner'

  assert hits.has_css? '.Dashboard-chart'
  assert top_traffic.text.include? "In order to show Top Applications you need to have at least one application sending traffic to the #{service_name}."
end

When(/^I (fold|unfold) service "([^"]*)"$/) do |action, service_name|
  step %{service "#{service_name}" is #{action == 'fold' ? 'unfolded' : 'folded'}}

  service = service_for_name(service_name)
  service.find('.DashboardSection-toggle').click
end
