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
    sso_authorizations = create_sso_authorizations(@user).map { |sso| [sso.id_token, sso.authentication_provider.system_name] }
    drops_sso_authorizations = @drop.sso_authorizations.map { |sso| [sso.id_token, sso.authentication_provider_system_name] }

    assert_same_elements sso_authorizations, drops_sso_authorizations
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
