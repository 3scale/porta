# frozen_string_literal: true

When "I follow {string} from the CMS dropdown" do |link|
  within '#cms-new-content-button' do
    find('.dropdown-toggle').click
    click_on link
  end
end
