# frozen_string_literal: true

When "the subscription will return an error when suspended" do
  ServiceContract.any_instance.stubs(:suspend).returns(false).once
end

When "the subscription will return an error when plan changed" do
  ServiceContract.any_instance.stubs(:change_plan).returns(false).once
end

When "I should see the bulk action failed with service subscription of {account}" do |account|
  # HACK: we're assuming the contract is with the provider's default service.
  contract = @provider.default_service.contracts.find_by(user_account_id: account.id)
  assert_match "There were some errors:\n(#{contract.account.org_name})", bulk_errors_container.text
end
