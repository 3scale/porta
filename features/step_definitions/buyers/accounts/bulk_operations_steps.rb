# frozen_string_literal: true

When "the account will return an error when approved" do
  Account.any_instance.stubs(:approve).returns(false).once
end

When "the account will return an error when plan changed" do
  Contract.any_instance.stubs(:change_plan).returns(false).once
end

When "I should see the bulk action failed with {account}" do |account|
  assert_match "There were some errors:\n#{account.name}", bulk_errors_container.text
end
