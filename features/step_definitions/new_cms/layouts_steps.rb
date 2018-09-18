Given /^a CMS Layout "(.+?)" of (provider ".+?")$/ do |name, provider|
  Factory(:cms_layout, :system_name => name, :provider => provider, :published => '{% content %}')
end
