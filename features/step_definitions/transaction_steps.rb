When /^buyer "([^\"]*)" makes (\d+|a) service transactions? with:$/ do |buyer_name, count, table|
  buyer_account = Account.find_by_org_name!(buyer_name)
  cinstance = buyer_account.bought_cinstance
  provider_account = buyer_account.provider_account

  usage = table.hashes.inject({}) do |memo, row|
    memo[row['Metric']] = row['Value']
    memo
  end

  count = 1 if count == 'a'

  count.to_i.times do
    Backend::Transaction.report!(:provider_account_id => provider_account.id,
                                 :service_id => provider_account.first_service!.id,
                                 :cinstance_id => cinstance.id,
                                 :usage => usage,
                                 :confirmed => true)
  end
end

When /^the buyer makes (\d+|a) service transactions? with:$/ do |count, table|
  step %(buyer "#{@buyer.name}" makes #{count} service transactions with:), table
end

# TODO: remove - legacy expression


# TODO: remove ... is it needed?
Given /^buyer "([^"]*)" has made a transaction with metric "([^"]*)" and value "([^"]*)"$/ do |buyer_name, metric_name, value|
  buyer_account = Account.find_by_org_name!(buyer_name)

  Backend::Transaction.report!(:cinstance => buyer_account.bought_cinstance,
                               :service_id => buyer_account.bought_cinstance.service.id,
                               :usage => {metric_name => value},
                               :confirmed => true)
end
