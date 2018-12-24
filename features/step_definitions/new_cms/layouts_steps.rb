Given /^a CMS Layout "(.+?)" of (provider ".+?")$/ do |name, provider|
  FactoryBot.create(:cms_layout, :system_name => name, :provider => provider, :published => '{% content %}')
end
