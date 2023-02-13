# frozen_string_literal: true

Given "the partial {string} of {provider} is" do |name, provider, body|
  FactoryBot.create(:cms_partial, :system_name => name, :provider => provider, :draft => body).publish!
end
