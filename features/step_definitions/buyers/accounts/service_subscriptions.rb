# frozen_string_literal: true

Given "{provider} has no service subscriptions" do |provider|
  assert_empty provider.service_contracts
end
