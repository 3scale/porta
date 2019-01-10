Given /^I have(?: a)? cms page "(.+?)" of (provider ".+?")$/i do |path, provider|
  FactoryBot.create(:cms_page, :path => path, :provider => provider)
end

Given /^I have(?: a)? cms page "(.+?)" of (provider ".+?") with markdown content$/i do |path, provider|
  FactoryBot.create(:cms_page, :path => path, :provider => provider, :handler => :markdown, :published => '# Markdown content')
end

Then /^I should see rendered markdown content$/ do
  page.should have_css('h1', :text => 'Markdown content')
end

Then /^(CMS Page ".+?") should have:/ do |page, table|
  table = table.transpose
  actual = table.headers.map do |header|

    header = header.parameterize('_').to_sym
    value = page.send(header)

    case header.to_sym

    when :layout
      value.title

    else
      value.to_s
    end
  end

  table.diff! [table.headers, actual]
end


When /^I visit to add a new page within section "([^\"]*)"$/ do | section_path |
  section = Section.find_by_path section_path
  visit new_cms_section_page_path(:section_id => section.id)
end

Then(/^preview draft link should link to "(.*?)"$/) do | path |
  popup = window_opened_by do
    find("#cms-preview-button").click_link("Preview")
  end

  page.within_window popup do
    assert_match path, current_path
  end
end
