def image_source
  image = find('img.preview', match: :one)
  image[:src]
end

When(/^the file is deleted$/) do
  find('a[href]', text: 'Download')[:href]
  click_on 'Delete', match: :one
  steps %q{
    Then I should see "deleted"
    Then there is not an image preview of that file
  }
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
  steps %q{
    When I attach the file "test/fixtures/tinnytim.jpg" to "cms_file_attachment"
    And I press "Save"
   }
end

And(/^the original file should be gone$/) do
  assert @previous_file

  assert_raise ActionController::RoutingError do
    visit @previous_file
  end
end

Then(/^there is (not )?an image preview of that file$/) do |negative|
  image_preview = 'img.preview'
  if negative
    page.should have_no_selector(image_preview)
  else
    page.should have_selector(image_preview)

    visit image_source
    steps %q{ Then the file should be the same as uploaded }
  end
end

def create_cms_file(path, file_path)
  steps %{
    Given I go to the cms page
    And I follow "New File" from the CMS dropdown
    And I fill in "Path" with "#{path}"
    And I attach the file "test/fixtures/#{file_path}" to "cms_file_attachment"
    And I press "Create File"
    Then I should see "Created new file"
  }
end

When(/^I upload a file that is not an image to the cms$/) do
  create_cms_file('file_not_image', 'countries.yml')
end

Given(/^there is a (downloadable )?cms file$/) do |downloadable|
  create_cms_file('image', 'hypnotoad.jpg')
  if downloadable.present?
    steps %q{
     Then I check "Downloadable"
     And I press "Save"
    }
  end
end
