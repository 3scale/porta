# frozen_string_literal: true

And "adds the echo Product" do
  within product_form do
    fill_in 'Product Name', with: 'Echo Product'
  end
end

And "adds the echo Backend" do
  within backend_form do
    fill_in 'Backend Name', with: 'Echo API'
    fill_in 'Base URL', with: 'https://echo-api.3scale.net'
  end
end

And "adds a path" do
  within connect_form do
    fill_in 'Path', with: ''
  end
end

And "goes to Add a Backend page" do
  click_on 'Got it! Lets add my API'

  page.should have_content 'Add your API(s)'
end

And "goes to Add a Product page" do
  within backend_form do
    click_on 'Add this Backend'
  end

  page.should have_content 'Design a Product'
end

And "goes to Connect page" do
  within product_form do
    click_on 'Add this Product'
  end

  page.should have_content 'Use your Backend in your Product'
end

And "goes to the request page" do
  within connect_form do
    click_on 'Add the Backend to the Product'
  end

  page.should have_content 'Good. Next, make a test GET request'
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
