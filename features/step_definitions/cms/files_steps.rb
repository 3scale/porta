def image_source
  image = find('img.preview', match: :one)
  image[:src]
end

When(/^the file is deleted$/) do
  find('a[href]', text: 'Download')[:href]
  accept_confirm do
    click_link 'Delete'
  end
  assert_page_has_content 'deleted'
  assert_page_has_no_content 'img.preview'
end

Then(/^the file should be the same as uploaded$/) do
  assert_page_is_file 'test/fixtures/hypnotoad.jpg'
end

When(/^I access the file on developer portal$/) do
  click_on('Visit Portal')
  file = URI(current_url).merge('/image')
  visit file
end

Then(/^the file should be downloaded$/) do
  page.driver.response_headers['Content-Disposition'].should include('attachment')
end

When(/^I update the file with different image$/) do
  @previous_file = image_source
  attach_file('cms_file_attachment', Rails.root.join('test/fixtures/tinnytim.jpg'))
  click_on "Save"
end

Then(/^the file should be updated$/) do
  visit image_source
  assert_page_is_file 'test/fixtures/tinnytim.jpg'
end

And(/^the original file should be gone$/) do
  assert @previous_file

  assert_raise ActionController::RoutingError do
    visit @previous_file
  end
end

def assert_page_is_file(file_name)
  file = File.read(File.expand_path(file_name), binmode: true)

  assert_equal file, page.source, "#{file_name} does not equal the page source"
end

Then(/^there is (not )?an image preview of that file$/) do |negative|
  image_preview = 'img.preview'
  if negative
    page.should have_no_selector(image_preview)
  else
    page.should have_selector(image_preview)

    visit image_source
    assert_page_is_file 'test/fixtures/hypnotoad.jpg'
  end
end

def create_cms_file(path, file_path)
  visit provider_admin_cms_templates_path
  step 'I follow "New File" from the CMS "New Page" dropdown'
  fill_in('Path', with: path)
  attach_file('cms_file_attachment', Rails.root.join("test/fixtures/#{file_path}"))
  click_button 'Create File'
  assert_page_has_content 'Created new file'
end

When(/^I upload a file that is not an image to the cms$/) do
  create_cms_file('file_not_image', 'countries.yml')
end

Given(/^there is a (downloadable )?cms file$/) do |downloadable|
  create_cms_file('image', 'hypnotoad.jpg')
  if downloadable.present?
    check 'Downloadable'
    click_button 'Save'
  end
end

When "I fill in the tags list with {string}" do |text|
  fill_in("Tag list", :with => text)
end

Then "I should see the tags {string}" do |text|
  page.should have_field('Tag list')
  expected_tags = text.split(",").map(&:strip)
  actual_tags = page.find_field("Tag list").value.split(",").map(&:strip)
  assert_equal Set.new(expected_tags), Set.new(actual_tags)
end
