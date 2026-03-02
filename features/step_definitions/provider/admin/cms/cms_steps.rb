# frozen_string_literal: true

Given "they select {string} from the CMS new content dropdown" do |option|
  cms_buttons_click('new-content', option)
end
