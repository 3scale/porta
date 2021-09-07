# frozen_string_literal: true

Before do |scenario|
  Sidekiq::Worker.clear_all

  countries = {'ES' => 'Spain',
    'US' => 'United States of America'}

  countries.each do |code, name|
    Country.create(name: name, code: code)
  end

  ThreeScale.config.stubs(superdomain: '3scale.localhost')

  SphinxIndexationWorker.stubs(:perform_later)
  IndexProxyRuleWorker.stubs(:perform_later)

  FieldsDefinition.create_defaults! master_account

  if scenario.source_tag_names.include?('@search')
    SphinxIndexationWorker.unstub(:perform_later)
    IndexProxyRuleWorker.unstub(:perform_later)
  end

  ThreeScale.config.stubs(onpremises: false)
  ThreeScale.config.sandbox_proxy.stubs(apicast_registry_url: 'http://apicast.alaska/policies')
  ThreeScale.config.sandbox_proxy.stubs(self_managed_apicast_registry_url: 'http://self-managed.apicast.alaska/policies')
end
