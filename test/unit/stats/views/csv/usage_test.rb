require File.expand_path(File.dirname(__FILE__) + '/../../../../test_helper')

class Stats::Views::Csv::UsageTest < ActiveSupport::TestCase

  def data
    { :period => {:name => "day", :since => DateTime.parse("2011-05-04T00:00:00+02:00")},
      :metrics => [
      {:system_name => 'foo_single_a', :name => "Foo Single A", :data => {:values => [1,2,3,4,5]}},
      {:system_name => 'foo_single_b', :name => "Foo Single B", :data => {:values => [6,7,8,9,0]}}
    ] }
  end

  test "sets a header for the CSV output" do
    csv = Stats::Views::Csv::Usage.new(data).to_csv

    actual_header = csv.lines.first.chomp
    expected_header = "Metric System Name,Metric Name,Date,Value"

    assert_equal expected_header, actual_header
  end


  test "CSV output includes usage data" do
    csv = Stats::Views::Csv::Usage.new(data).to_csv

    actual_data_row_1 = csv.lines.to_a[1].chomp
    expected_data_row_1 = "foo_single_a,Foo Single A,2011-05-04T00:00:00+02:00,1"

    actual_data_row_2 = csv.lines.to_a[2].chomp
    expected_data_row_2 = "foo_single_a,Foo Single A,2011-05-04T01:00:00+02:00,2"

    actual_data_final_row = csv.lines.to_a.last.chomp
    expected_data_final_row = "foo_single_b,Foo Single B,2011-05-04T04:00:00+02:00,0"

    assert_equal expected_data_row_1, actual_data_row_1
    assert_equal expected_data_row_2, actual_data_row_2
    assert_equal expected_data_final_row, actual_data_final_row
  end

end
