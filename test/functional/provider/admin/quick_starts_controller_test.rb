# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::QuickStartsControllerTest < ActionController::TestCase
  def setup
    rolling_updates_on
    provider = FactoryBot.create(:provider_account)
    login_provider(provider)
  end

  class RollingUpdateOnTest < self
    def setup
      super
      rolling_update(:quick_starts, enabled: true)
    end

    test '#show' do
      get :show
      assert_response :ok
    end
  end

  class RollingUpdateOffTest < self
    def setup
      super
      rolling_update(:quick_starts, enabled: false)
    end

    test 'raises not found' do
      assert_raise(ActionController::RoutingError) { get :show }
    end
  end
end
