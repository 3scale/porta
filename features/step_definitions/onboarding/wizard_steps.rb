# frozen_string_literal: true

And(/^adds the echo Product$/) do
  within product_form do
    fill_in 'Product Name', with: 'Echo Product'
  end
end

And(/^adds the echo Backend$/) do
  within backend_form do
    fill_in 'Backend Name', with: 'Echo API'
    fill_in 'Base URL', with: 'https://echo-api.3scale.net'
  end
end

And(/^adds a path$/) do
  within connect_form do
    fill_in 'Path', with: ''
  end
end

And(/^goes to Add a Backend page$/) do
  click_on 'Got it! Lets add my API'

  page.should have_content 'Add your API(s)'
end

And(/^goes to Add a Product page$/) do
  within backend_form do
    click_on 'Add this Backend'
  end

  page.should have_content 'Design a Product'
end

And(/^goes to Connect page$/) do
  within product_form do
    click_on 'Add this Product'
  end

  page.should have_content 'Use your Backend in your Product'
end

And(/^goes to the request page$/) do
  within connect_form do
    click_on 'Add the Backend to the Product'
  end

  page.should have_content 'Good. Next, make a test GET request'
end

When(/^user starts the onboarding wizard$/) do
  click_on 'OK, how does 3scale work?'
end

And(/^sends the test request$/) do
  stub_request(:get, %r{//test.proxy/deploy/}).to_return(status: 200)
  stub_request(:get, /staging.apicast.dev/).to_return(status: 200, body: 'Hey! successful request')

  click_on 'Send request'

  page.should have_content 'Congratulations, you are running on 3scale :-)'
end

And(/^goes to what's next$/) do
  click_on "Cool, what's next?"
  page.should have_content "What's next?"
end

Then(/^goes to API page$/) do
  click_on 'Got it! Take me to my API on 3scale'
  page.should have_content 'Overview'
  page.should have_content api_name
end

def product_form
  find('#product_form')
end

def backend_form
  find('#backend_api_form')
end

def connect_form
  find('#connect_form')
end

def api_name
  'Echo API'
end
