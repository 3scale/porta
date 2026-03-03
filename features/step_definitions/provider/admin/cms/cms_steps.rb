# frozen_string_literal: true

Given "they select {string} from the CMS new content dropdown" do |option|
  cms_buttons_click('new-content', option)
end

Given "(they )select {string} from the CMS sidebar" do |name|
  within '#cms-sidebar-content' do
    find("[data-search='#{name}']").click
    wait_for_requests
  end
end
