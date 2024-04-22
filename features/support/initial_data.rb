# frozen_string_literal: true

Before do |scenario|
  Sidekiq::Job.clear_all

  countries = {'ES' => 'Spain',
    'US' => 'United States of America'}

  countries.each do |code, name|
    Country.create(name: name, code: code)
  end

  ThreeScale.config.stubs(superdomain: '3scale.localhost')

  FieldsDefinition.create_defaults! master_account

  ThreeScale.config.stubs(onpremises: false)
  ThreeScale.config.stubs(saas?: true)
  ThreeScale.config.sandbox_proxy.stubs(apicast_registry_url: 'http://apicast.alaska/policies')
  ThreeScale.config.sandbox_proxy.stubs(self_managed_apicast_registry_url: 'http://self-managed.apicast.alaska/policies')
end
