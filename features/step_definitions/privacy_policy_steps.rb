# frozen_string_literal: true

Given "the privacy policy of provider {string} is blank" do |provider_name|
  provider_account = Account.find_by!(org_name: provider_name)
  provider_account.settings.privacy_policy = nil
  provider_account.settings.save!
end

