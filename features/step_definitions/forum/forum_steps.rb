Given /^the forum of (provider "[^\"]*") is private$/ do |provider|
  provider.settings.update_attribute :forum_public, false
end

Given /^the forum of (provider "[^\"]*") is public$/ do |provider|
  provider.settings.update_attribute :forum_public, true
end
