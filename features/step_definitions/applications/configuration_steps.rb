Given /^the (provider "[^\"]*") does not allow its partners to manage applications$/ do |provider|
  provider.default_service.update_attribute :buyers_manage_apps, false
end

Given /^the (provider "[^\"]*") does not allow its partners to manage application keys$/ do |provider|
  provider.default_service.update_attribute :buyers_manage_apps, true
  provider.default_service.update_attribute :buyers_manage_keys, false
end


Given /^the (provider "[^\"]*") allows its partners to select a plan$/ do |provider|
  ActiveSupport::Deprecation.warn('Use "service NAME allows to choose plan on app creation"')
  provider.default_service.update_attribute :buyer_can_select_plan, true
end

