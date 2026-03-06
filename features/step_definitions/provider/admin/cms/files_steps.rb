# frozen_string_literal: true

Given(/^a (downloadable )?CMS file$/) do |downloadable|
  @cms_file = FactoryBot.create(:cms_file, provider: @provider, downloadable:)
end

When "attach the file located at {string}" do |path|
  attach_file('cms_file_attachment', path)
end
