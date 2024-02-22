# frozen_string_literal: true

When "the subscription will return an error when suspended" do
  ServiceContract.any_instance.stubs(:suspend).returns(false).at_least_once
end

When "the subscription will return an error when changing its plan" do
  ServiceContract.any_instance.stubs(:change_plan).returns(false).at_least_once
end
