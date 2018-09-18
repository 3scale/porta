When(/^user starts the onboarding wizard$/) do
  click_on 'OK, how does 3scale work?'
end

And(/^adds the echo api$/) do
  click_on 'Got it! Lets add my API'

  within api_form do
    fill_in 'Name', with: 'Echo API'
    fill_in 'Base URL', with: 'https://echo-api.3scale.net'

    click_on 'Add this API'
  end
end

And(/^sends the test request$/) do
  stub_request(:get, %r{//test.proxy/deploy/}).to_return(status: 200)
  stub_request(:get, /staging.apicast.dev/).to_return(status: 200, body: response = 'Hey! successful request')

  click_on 'Send request'

  page.should have_content 'Congratulations, you are running on 3scale :-)'

end

def api_form
  find('#api_form')
end

And(/^goes to what's next$/) do
  click_on "Cool, what's next?"
  page.should have_content "What's next?"
end

Then(/^goes to API page$/) do
  click_on 'Got it! Take me to my API on 3scale'
  page.should have_content 'Configure APIcast'
end
