# frozen_string_literal: true

Then "(I )(they )should see the provider key of {provider}" do |provider|
  within '#key-overview .key' do
    assert_text provider.api_key
  end
end
