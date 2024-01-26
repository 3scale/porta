# frozen_string_literal: true

Then "{buyer} should( still) have {int} cinstance(s)" do |buyer_account, number|
  assert_equal number.to_i, buyer_account.bought_cinstances.count
end

Given "the following alerts:" do |table|
  transform_alerts_table(table).hashes.each do |hash|
    app = hash.delete('application')
    Alert.create!([hash.merge(account: app.user_account, cinstance: app),
                   hash.merge(account: app.service.account, cinstance: app)])
  end
end
