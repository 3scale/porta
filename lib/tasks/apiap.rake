# frozen_string_literal: true

namespace :apiap do
  task sample: :environment do
    master = Account.master

    # provider
    provider = Account.create!(name: 'Product Seller') do |account|
      account.subdomain = 'prodsell'
      account.provider_account = master
      account.provider = true
      account.sample_data = true
    end
    provider.approve!
    provider.create_onboarding!
    provider.force_upgrade_to_provider_plan!(master.default_service.default_application_plan)

    # admin user
    user = User.create!(username: 'admin', password: 'p', password_confirmation: 'p') do |user|
      user.signup_type = :minimal
      user.account = provider
      user.role = :admin
      user.email = 'admin+test@prodsel.fake'
    end
    user.activate!

    # impersonation admin
    impersonation_admin = provider.users.build_with_fields
    impersonation_admin.account = provider
    impersonation_admin.role = :admin
    impersonation_admin.signup_type = :minimal
    impersonation_admin_config = ThreeScale.config.impersonation_admin
    impersonation_admin_username = impersonation_admin_config['username']
    impersonation_admin.attributes = {
      username: impersonation_admin_username,
      email: "#{impersonation_admin_username}+#{provider.self_domain}@#{impersonation_admin_config['domain']}",
      first_name: '3scale',
      last_name: 'Admin'
    }
    impersonation_admin.save!
    impersonation_admin.activate!

    # swicthes
    Settings.basic_enabled_switches.each { |name| provider.settings.public_send("show_#{name}!") }
    Settings.basic_disabled_switches.each { |name| provider.settings.public_send("hide_#{name}!") }

    # create sample data and import cms templates
    provider.create_sample_data!
    provider.import_simple_layout!

    # apiap products and backends
    echo_product = provider.default_service
    echo_product.update_attributes(act_as_product: true, name: 'Echo Product')

    echo_api = echo_product.backend_api
    echo_api.update_attributes(name: 'Echo API', description: 'Actual backend implementation of the Echo API')

    secret_api = provider.backend_apis.create(name: 'Secret API', system_name: 'secret-api', description: 'This is my secret backend API', private_endpoint: 'https://secret-api.fake-server.test:443')
    echo_product.backend_api_configs.create(backend_api: secret_api, path: 'secret')

    colors_product = provider.services.create(name: 'Colors Product', system_name: 'colors-api', description: 'Color info by reference', act_as_product: true)
    colors_product.backend_api.destroy

    rgb_api = provider.backend_apis.create(name: 'RGB API', system_name: 'rgb-api', description: 'RGB color references', private_endpoint: 'https://rgb.net:443/api')
    pantone_api = provider.backend_apis.create(name: 'Pantone API', system_name: 'pantone-api', description: "The famous palette of Pantone's", private_endpoint: 'https://api.pantone.com:443')
    colors_product.backend_api_configs.create(backend_api: rgb_api, path: 'rgb')
    colors_product.backend_api_configs.create(backend_api: pantone_api, path: 'pantone')
    colors_product.backend_api_configs.create(backend_api: secret_api, path: 'secret')

    colors_product.application_plans.create(name: 'Web development', system_name: 'web-plan', description: 'Only for FE devs')
    colors_product.application_plans.create(name: 'Printing', system_name: 'printing-plan', description: 'Plotting companies')

    # backend api metrics and mapping rules
    echo_hits = echo_api.metrics.create(friendly_name: 'Hits', system_name: 'hits', unit: 'hit')
    loud_metric = echo_hits.children.create(friendly_name: 'Loud echo', system_name: 'loud', unit: 'hit', description: 'A very loud echo')
    low_metric = echo_hits.children.create(friendly_name: 'Low echo', system_name: 'low', unit: 'hit', description: 'A not so loud echo')

    secret_hits = secret_api.metrics.create(friendly_name: 'Hits', system_name: 'hits', unit: 'hit')
    secret_ads = secret_api.metrics.create(friendly_name: 'Ads', system_name: 'ads', unit: 'hit', description: 'Only for advertising')

    echo_api.proxy_rules.create(http_method: 'GET', pattern: '/loud', metric: loud_metric, metric_system_name: loud_metric.system_name, delta: 1, position: 1)
    echo_api.proxy_rules.create(http_method: 'GET', pattern: '/low', metric: low_metric, metric_system_name: low_metric.system_name, delta: 1, position: 2)

    secret_api.proxy_rules.create(http_method: 'GET', pattern: '/ads', metric: secret_ads, metric_system_name: secret_ads.system_name, delta: 1, position: 1)
    secret_api.proxy_rules.create(http_method: 'GET', pattern: '/', metric: secret_hits, metric_system_name: secret_ads.system_name, delta: 1, position: 2)
  end
end
