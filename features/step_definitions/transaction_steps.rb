# frozen_string_literal: true

When "buyer {string} makes a service transaction with:" do |buyer_name, count, table|
  step %(buyer "#{buyer_name}" makes 1 service transaction with:)
end

When "buyer {string} makes {int} service transaction(s) with:" do |buyer_name, count, table|
  buyer_account = Account.find_by!(org_name: buyer_name)
  cinstance = buyer_account.bought_cinstance
  provider_account = buyer_account.provider_account

  usage = table.hashes.each_with_object({}) do |row, memo|
    memo[row['Metric']] = row['Value']
  end

  count.times do
    Backend::Transaction.report!(provider_account_id: provider_account.id,
                                 service_id: provider_account.first_service!.id,
                                 cinstance_id: cinstance.id,
                                 usage: usage,
                                 confirmed: true)
  end
end

When "the buyer makes a service transaction with:" do |table|
  step %(the buyer makes 1 service transaction with:), table
end

When "the buyer makes {int} service transaction(s) with:" do |count, table|
  step %(buyer "#{@buyer.name}" makes #{count} service transactions with:), table
end

# FIXME: supressed for testing purposes, if all green then remove
# Given /^buyer "([^"]*)" has made a transaction with metric "([^"]*)" and value "([^"]*)"$/ do |buyer_name, metric_name, value|
  # buyer_account = Account.find_by!(org_name: buyer_name)

  # Backend::Transaction.report!(:cinstance => buyer_account.bought_cinstance,
  #                              :service_id => buyer_account.bought_cinstance.service.id,
  #                              :usage => {metric_name => value},
  #                              :confirmed => true)
# end
