Given /^(provider "[^"]*") has the following latest transactions:$/ do |provider, table|
  fake_transactions(provider.default_service, table)
end

Given /^(provider "[^"]*") has the following latest transactions in (service "[^"]*"):$/ do |provider, service, table|
  fake_transactions(service, table)
end

Given /^(provider "[^"]*") has no latest transactions$/ do |provider|
  transactions = ThreeScale::Core::APIClient::Collection.new([])
  ThreeScale::Core::Transaction.stubs(:load_all).with(provider.default_service.backend_id).returns(transactions)
end

Then /^I should see the following transactions:$/ do |table|
  data = process_transaction_table(table)

  table_node = find('#latest_transactions')

  data.each do |hash|
    assert table_node.has_css?('td', :text => hash[:buyer])
    assert table_node.has_css?('td', :text => hash[:timestamp])

    hash["Usage"].each do |name, value|
      assert(table_node.all('tr').any? do |tr|
        tr.has_css?('td', :text => name)
        tr.has_css?('td', :text => value)
      end)
    end
  end
end

def parse_hash(input)
  input.split(',').inject({}) do |memo, part|
    key, value = part.strip.split(':').map(&:strip)

    memo[key] = value
    memo
  end
end

def process_transaction_table(table)
  table.hashes.each do |row|
    row["Usage"] = parse_hash(row["Usage"])
  end
  table.hashes
end

def fake_transactions(service, table)
  data = process_transaction_table(table)

  transactions = data.map do |hash|
    application_id = if hash["Buyer"] == 'INVALID'
                       hash["Buyer"]
                     else
                       Account.find_by_org_name!(hash["Buyer"]).bought_cinstance.application_id
                     end

    usage = hash["Usage"].inject({}) do |memo, (metric_name, value)|
      metric_id = if metric_name == 'INVALID'
                    metric_name
                  else
                    service.metrics.find_by!(system_name: metric_name).id
                  end
      memo[metric_id.to_s] = value
      memo
    end

    { application_id: application_id, timestamp: hash['Timestamp'], usage: usage }
  end

  transactions.map! { |attr| ThreeScale::Core::Transaction.new(attr.deep_symbolize_keys) } # usage keys (the metric ids) are actually provided as Symbol by ThreeScale::Core
  transactions = ThreeScale::Core::APIClient::Collection.new(transactions)
  ThreeScale::Core::Transaction.stubs(:load_all).with(service.backend_id).returns(transactions)
end
