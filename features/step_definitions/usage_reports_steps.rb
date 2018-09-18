Given /^mail dispatch rule "(.*)\/(.*)" is set to "([^\"]*)"$/ do |domain, ref, boolean|
  account = Account.find_by_domain domain
  operation = SystemOperation.for(ref)
  rule = account.dispatch_rule_for(operation)
  rule.update_attribute(:dispatch, boolean == 'true' ? true : false)
  rule.reload
end

When /^weekly reports are dispatched$/ do
  Pdf::Dispatch.weekly
end

When /^daily reports are dispatched$/ do
  Pdf::Dispatch.daily
end
