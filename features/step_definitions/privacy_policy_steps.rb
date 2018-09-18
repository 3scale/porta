Given /^the privacy policy of provider "([^\"]*)" is blank$/ do |provider_name|
  provider_account = Account.find_by_org_name!(provider_name)
  provider_account.settings.privacy_policy = nil
  provider_account.settings.save!
end

