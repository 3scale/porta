# frozen_string_literal: true

Given "I have (a )cms page {string} of {provider}" do |path, provider|
  FactoryBot.create(:cms_page, :path => path, :provider => provider)
end

Given "I have (a )cms page {string} of {provider} with markdown content" do |path, provider|
  FactoryBot.create(:cms_page, :path => path, :provider => provider, :handler => :markdown, :published => '# Markdown content')
end

Then /^I should see rendered markdown content$/ do
  page.should have_css('h1', :text => 'Markdown content')
end

Then "{cms_page} should have:" do |page, table|
  table = table.transpose
  actual = table.headers.map do |header|

    header = header.parameterize(separator: '_').to_sym
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

Then(/^preview draft link should link to "(.*?)"$/) do | path |
  popup = window_opened_by do
    find("#cms-preview-button").click_link("Preview")
  end

  page.within_window popup do
    assert_match path, current_path
  end
end
