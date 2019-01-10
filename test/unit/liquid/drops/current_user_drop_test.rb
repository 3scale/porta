# frozen_string_literal: true

require 'test_helper'

class Liquid::Drops::CurrentUserDropTest < ActiveSupport::TestCase
  include Liquid

  def setup
    @user = FactoryBot.create(:user_with_account)
    @drop = Drops::CurrentUser.new(@user)
  end

  test "#can" do
    assert @drop.respond_to?(:can)
    assert_kind_of Liquid::Drops::CurrentUser::Can, @drop.can
  end

  # test "#can.manage_multiple_users?" do
  #   assert @drop.can.respond_to?(:manage_multiple_users?)
  # end

  test "#can.invite_users?" do
    assert @drop.can.respond_to?(:invite_users?)
  end

  test "#can.create_application?" do
    assert @drop.can.respond_to?(:create_application?)
  end

  test "not respond to the User::Can methods" do
    assert !@drop.can.respond_to?(:be_destroyed?)
    assert !@drop.can.respond_to?(:be_managed?)
    assert !@drop.can.respond_to?(:be_update_role?)
  end

  test '#sso_authorizations' do
    sso_authorizations = create_sso_authorizations(@user)
    assert_equal sso_authorizations.size, @drop.sso_authorizations.size

    assert_equal sso_authorizations.first.id_token, @drop.sso_authorizations.first.id_token
    assert_equal sso_authorizations.first.authentication_provider.system_name, @drop.sso_authorizations.first.authentication_provider_system_name

    assert_equal sso_authorizations.last.id_token, @drop.sso_authorizations.last.id_token
    assert_equal sso_authorizations.last.authentication_provider.system_name, @drop.sso_authorizations.last.authentication_provider_system_name
  end

  private

  def create_sso_authorizations(user)
    authorizations = []
    %i[keycloak_authentication_provider github_authentication_provider].each do |authentication_provider_sym|
      authorizations << FactoryBot.create(:sso_authorization, user: user, authentication_provider: FactoryBot.create(authentication_provider_sym) )
    end
    authorizations
  end
end
