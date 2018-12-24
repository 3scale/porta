require 'test_helper'

class Tasks::BackendTest < ActiveSupport::TestCase
  include TestHelpers::FakeWeb

  test 'storage:rewrite' do
    provider = FactoryBot.create(:provider_account)
    buyer    = FactoryBot.create(:buyer_account, provider_account: provider)
    app      = FactoryBot.create(:cinstance, user_account: buyer)
    key, filter = nil

    BackendClient::ToggleBackend.without_backend do
      key    = FactoryBot.create(:application_key, application: app)
      filter = FactoryBot.create(:referrer_filter, application: app)
    end

    expect_backend_create_key(app, key.value)
    expect_backend_create_referrer_filter(app, filter.value)

    Rails.env.stubs(test?: false)
    System::Application.config.three_scale.core.expects(fake_server: false)

    execute_rake_task 'backend.rake', 'backend:storage:rewrite'
  end
end
