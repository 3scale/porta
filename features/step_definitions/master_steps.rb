Given(/^the master account allows signups$/) do
  provider = master_account # Ensure that the master account exists, otherwise it creates it

  provider.settings.deny_multiple_applications! if provider.settings.can_deny_multiple_applications?

  service = provider.first_service!
  service.publish!
  provider.update!(default_account_plan: provider.account_plans.first)

  plans = service.service_plans
  plans.default!(plans.default_or_first || plans.first)

  FactoryBot.create(:application_plan, name: 'Base', issuer: service, default: true)
end
