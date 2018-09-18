
Then /^I should see the following log entries:$/ do |table|
  table.hashes.each do |log_entry|
    step %{I should see log entry "#{log_entry[:text]}" with level "#{log_entry[:level]}" on "#{log_entry[:time]}"}
  end
end
