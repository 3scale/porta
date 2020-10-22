# frozen_string_literal: true

Given "a CMS Layout {string} of {provider}" do |name, provider|
  FactoryBot.create(:cms_layout, system_name: name, provider: provider, published: '{% content %}')
end
