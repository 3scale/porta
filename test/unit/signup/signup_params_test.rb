# frozen_string_literal: true

require 'test_helper'

module Signup
  class SignupParamsTest < ActiveSupport::TestCase
    test '#plans returns the plans param' do
      assert_equal signup_params_hash[:plans], signup_params.plans
    end

    test '#defaults return the defaults param' do
      assert_equal signup_params_hash[:defaults], signup_params.defaults
    end

    private

    def signup_params
      @signup_params ||= Signup::SignupParams.new(user_attributes: user_params, account_attributes: account_params, plans: [], defaults: {})
    end

    def signup_params_hash
      { user_attributes: user_params, account_attributes: account_params, plans: [], defaults: {} }
    end

    def account
      @account ||= Account.new(account_params)
    end

    def provider_account
      @provider_account ||= FactoryBot.create(:provider_account)
    end

    def user_params
      { email: 'emailTest@email.com', username: 'john', first_name: 'John', last_name: 'Doe',
        password: '123456', password_confirmation: '123456', signup_type: :minimal }
    end

    def account_params
      { org_name: 'Developer', vat_rate: 33 }
    end
  end
end
