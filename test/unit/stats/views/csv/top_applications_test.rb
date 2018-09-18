require File.expand_path(File.dirname(__FILE__) + '/../../../../test_helper')

class Stats::Views::Csv::TopApplicationsTest < ActiveSupport::TestCase

  def applications_data
    {:applications => [
      {:name => "FooBar", :id => 1234, :plan => {:name => "FooBar Plan Name", :id => 12345}, :account => {:name => "FooBar Account Name", :id => 67890}, :value => 100}
    ]}
  end

  test "sets a header for the CSV output" do
    csv = Stats::Views::Csv::TopApplications.new(applications_data).to_csv

    actual_header = csv.lines.first.chomp
    expected_header = "Application Name,Application ID,Plan Name,Plan ID,Account Name,Account ID,Total"

    assert_equal expected_header, actual_header
  end


  test "CSV output includes application data" do
    csv = Stats::Views::Csv::TopApplications.new(applications_data).to_csv

    actual_data = csv.lines.to_a[1].chomp
    expected_data = "FooBar,1234,FooBar Plan Name,12345,FooBar Account Name,67890,100"

    assert_equal expected_data, actual_data
  end

end
