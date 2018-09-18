Given(/^(provider ".*?") has all the templates setup$/) do |provider|
  provider.files.delete_all
  provider.templates.delete_all
  SimpleLayout.new(provider).import!
end

Given(/^the provider (has all the templates setup)$/) do |sentence|
  step %(provider "#{@provider.domain}" #{sentence})
end

Given('provider has opt-out for credit card workflow on plan changes') do
  search = '{% plan_widget application, wizard: true %}'
  replacement = '{% plan_widget application, wizard: false %}'
  partial = @provider.builtin_partials.find_by_system_name! 'applications/form'
  draft = partial.published.dup
  assert draft.gsub!(search, replacement), 'failed to enable the wizard'
  partial.draft = draft
  partial.publish!

  page = @provider.builtin_pages.find_by_system_name! 'applications/show'
  draft = page.published.dup
  assert draft.gsub!(search, replacement), 'failed to enable the wizard'
  page.draft = draft
  page.publish!
end
