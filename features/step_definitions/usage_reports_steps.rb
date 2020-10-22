# frozen_string_literal: true

Given "mail dispatch rule \"{}\/{}\" is set to {string}" do |domain, ref, boolean|
  account = Account.find_by!(domain: domain)
  operation = SystemOperation.for(ref)
  rule = account.dispatch_rule_for(operation)
  rule.update!(dispatch: boolean == 'true')
  rule.reload
end

When "weekly reports are dispatched" do
  Pdf::Dispatch.weekly
end

When "daily reports are dispatched" do
  Pdf::Dispatch.daily
end
