Given(/^a provider has a developer "(.*?)" with an application name "(.*?)"$/) do |developer_name, developer_app_name|
  steps %{
    Given a provider "foo.3scale.localhost"
    And an application plan "Default" of provider "foo.3scale.localhost"
    And a buyer "#{developer_name}" signed up to provider "foo.3scale.localhost"
    And buyer "#{developer_name}" has application "#{developer_app_name}"
  }
end

Given("the buyer made {int} service transactions {int} hours ago:") do |transactions_number, hours, table|
  travel_to(hours.hours.ago)
  access_user_sessions
  step %'the buyer makes #{transactions_number} service transactions with:', table
end

Then "the Current Utilization panel should contain the following data:" do |table|
  assert_text "Overview of the current state of this application's limits"
  within "#application-utilization" do
    utilization_table = extract_pf4_table
    assert_same_elements table.raw, utilization_table
  end
end
