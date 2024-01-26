# frozen_string_literal: true

Then "they should see {the_user_key_of_buyer}" do |key|
  assert_selector(:css, '#user-key', text: key)
end

Then "(they )should not see the ID of {application}" do |application|
  binding.pry
end

Then "(they )should see the ID of the application of {buyer}" do |buyer|
  assert_text(buyer.bought_cinstance.application_ id)
end

Then "(I )(they )should see the provider key of {provider}" do |provider|
  within '#key-overview .key' do
    assert_text provider.reload.api_key
  end
end
