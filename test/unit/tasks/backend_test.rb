require 'test_helper'

module Tasks
  class BackendTest < ActiveSupport::TestCase
    test 'storage:rewrite' do
      provider = FactoryBot.create(:provider_account)
      service  = FactoryBot.create(:simple_service, account: provider)
      plan     = FactoryBot.create(:simple_application_plan, issuer: service)
      buyer    = FactoryBot.create(:buyer_account, provider_account: provider)
      app      = FactoryBot.create(:cinstance, plan: plan, user_account: buyer)
      key, filter = nil

      BackendClient::ToggleBackend.without_backend do
        key    = FactoryBot.create(:application_key, application: app)
        filter = FactoryBot.create(:referrer_filter, application: app)
      end

      ThreeScale::Core::Application.stubs(:save_batch)
      ThreeScale::Core::Application.expects(:save_batch).once.with do |_service_id, applications|
        app_attrs = applications.find { _1[:id] == app.application_id }
        app_attrs &&
          app_attrs[:application_keys].include?(key.value) &&
          app_attrs[:referrer_filters].include?(filter.value)
      end

      Rails.env.stubs(test?: false)
      System::Application.config.three_scale.core.expects(fake_server: false)

      execute_rake_task 'backend.rake', 'backend:storage:rewrite'
    end
  end
end
