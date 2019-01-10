# frozen_string_literal: true
require 'test_helper'

class Provider::ActivationsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider = FactoryBot.create(:provider_account)
    @user = FactoryBot.create(:pending_user, account: @provider)

    host! @provider.admin_domain
  end

  test 'create' do
    get provider_activate_path activation_code: @user.activation_code

    assert_response :redirect
  end

  test 'activate a user creates onboarding process' do
    assert_equal false, @provider.onboarding.persisted?

    get provider_activate_path activation_code: @user.activation_code

    assert_equal true, @provider.reload.onboarding.persisted?
  end

  test 'creates onborading just once' do
    @provider.create_onboarding!

    assert_no_difference Onboarding.method(:count) do
      get provider_activate_path activation_code: @user.activation_code
      assert_response :redirect
    end
  end

  test 'does not try anything on HEAD request' do
    @user.activate!
    @user.update_column :activation_code, 'new-code-for-testing'
    head provider_activate_path activation_code: @user.activation_code
    assert_response :success
    assert response.body.blank?
  end

end
