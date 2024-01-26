Then "the Current Utilization panel contains the following data:" do |table|
  assert_text "Overview of the current state of this application's limits"
  within "#application-utilization" do
    utilization_table = extract_pf4_table
    assert_same_elements table.raw, utilization_table
  end
end
