# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::QuickstartsControllerTest < ActionController::TestCase
  def setup
    rolling_updates_on
    provider = FactoryBot.create(:provider_account)
    login_provider(provider)
  end

  class FeatureOnTest < self
    setup do
      Features::QuickstartsConfig.stubs(enabled?: true)
    end

    test '#show' do
      get :show
      assert_response :ok
    end
  end

  class FeatureOffTest < self
    setup do
      Features::QuickstartsConfig.stubs(enabled?: false)
    end

    test 'raises not found' do
      assert_raise(ActionController::RoutingError) { get :show }
    end
  end
end
