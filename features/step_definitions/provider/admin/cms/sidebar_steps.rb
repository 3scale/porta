# frozen_string_literal: true

Then "(they )should see the sidebar item {string} highlighted" do |name|
  within '#cms-sidebar' do
    expect(page).to have_css("a.current", text: name)
  end
end

def find_sidebar_section(title)
  link = find('a', text: /\A#{Regexp.escape(title)}\z/)
  link.find(:xpath, '..')
end

When "(they )toggle the sidebar section {string}" do |title|
  within '#cms-sidebar' do
    section = find_sidebar_section(title)
    section.find('.fa', match: :first).click
    wait_for_requests
  end
end

Then /^the sidebar section "([^"]*)" should be (collapsed|expanded)$/ do |title, state|
  within '#cms-sidebar' do
    section = find_sidebar_section(title)
    section_ul = section.find('ul', visible: :all)
    expect(section_ul[:class].include?('packed')).to eq(state == 'collapsed')
  end
end

When "(they )click on the collapse all button in the CMS sidebar" do
  within '#cms-sidebar' do
    find('#cms-sidebar-collapse-all').click
    wait_for_requests
  end
end

Then /^all top-level sidebar sections should be (collapsed|expanded)$/ do |state|
  within '#cms-sidebar-content' do
    root_ul = find("ul:first-child > li > ul")
    root_ul.find_all(":scope > [data-behavior~='toggle'] > ul").each do |section_ul|
      expect(section_ul[:class].include?('packed')).to eq(state == 'collapsed')
    end
  end
end

Then "the toggle cookie should contain the section {string}" do |title|
  raw_cookie = page.evaluate_script("document.cookie").match(/cms-toggle-ids=([^;]+)/)&.captures&.first
  expect(raw_cookie).not_to be_nil, "cms-toggle-ids cookie is not set"
  ids = JSON.parse(URI.decode_www_form_component(raw_cookie))

  within '#cms-sidebar' do
    section = find_sidebar_section(title)
    section_ul_id = section.find('ul', visible: :all)[:id]
    expect(ids).to include(section_ul_id), "Expected cookie #{ids} to contain '#{section_ul_id}' for '#{title}'"
  end
end

When "(they )fill in the CMS sidebar filter with {string}" do |text|
  within '#cms-sidebar' do
    fill_in_field = find('#cms-filter input')
    fill_in_field.set(text)
    fill_in_field.native.send_keys(:return)
  end
end
