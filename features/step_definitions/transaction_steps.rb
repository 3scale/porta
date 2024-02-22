# frozen_string_literal: true

When "{buyer} makes {amount} service transaction(s) with:" do |buyer_account, count, table|
  buyer_makes_service_transactions(buyer_account, count, table)
end

Given "{buyer} made {int} service transactions {int} hours ago:" do |buyer, count, hours, table|
  travel_to(hours.hours.ago)
  access_user_sessions
  buyer_makes_service_transactions(buyer, count, table)
end

def buyer_makes_service_transactions(buyer_account, count, table)
  cinstance = buyer_account.reload.bought_cinstance
  provider_account = buyer_account.provider_account

  usage = table.hashes.each_with_object({}) do |row, memo|
    memo[row['Metric']] = row['Value']
  end
  count.to_i.times do
    Backend::Transaction.report!(:provider_account_id => provider_account.id,
                                 :service_id => provider_account.first_service!.id,
                                 :cinstance_id => cinstance.id,
                                 :usage => usage)
  end
end

Given "the backend responds to a utilization request for {application} with:" do |application, table|
  json = { status: 'found', utilization: table.hashes }.to_json
  url = "/internal/services/#{application.service_id}/applications/#{application.application_id}/utilization/"
  TestHelpers::Backend::MockCore.stubs.get(url) { [200, {'content-type'=>'application/json'}, json] }
end
