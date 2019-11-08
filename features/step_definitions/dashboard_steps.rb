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

When(/^service "([^"]*)" is (folded|unfolded)$/) do |service_name, state|
  service = service_for_name(service_name)

  assert     service[:class].include? 'is-closed' if state == 'folded'
  assert_not service[:class].include? 'is-closed' if state == 'unfolded'
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

When(/^I (fold|unfold) service "([^"]*)"$/) do |action, service_name|
  step %(service "#{service_name}" is #{action == 'fold' ? 'unfolded' : 'folded'})

  service = service_for_name(service_name)
  service.find('.DashboardSection-toggle').click
end

When(/^I select the (products|backends) tab$/) do |tab|
  find('button', id: "tab-#{tab}").click
end


When (/^I search for "([^"]*)" using the (products|backends) search bar/) do |query, tab|
  search_bar = find("##{tab}_search").find('input[type="search"]')
  search_bar.send_keys query
end
