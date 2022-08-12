# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::QuickstartsControllerTest < ActionController::TestCase
  def setup
    provider = FactoryBot.create(:provider_account)
    login_provider(provider)
  end

  test '#show' do
    get :show
    assert_response :ok
  end
end
