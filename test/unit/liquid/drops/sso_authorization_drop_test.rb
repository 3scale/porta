# frozen_string_literal: true

require 'test_helper'

class Liquid::Drops::SSOAuthorizationDropTest < ActiveSupport::TestCase
  include Liquid

  def setup
    @authorization = FactoryGirl.build(:sso_authorization)
    @drop = Drops::SSOAuthorization.new(@authorization)
  end

  test '#id_token' do
    assert_equal @authorization.id_token, @drop.id_token
  end

  test '#authentication_provider_system_name' do
    assert_equal @authorization.authentication_provider.system_name, @drop.authentication_provider_system_name
  end
end
