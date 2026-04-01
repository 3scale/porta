# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::User::AccessTokensIndexPresenterTest < ActiveSupport::TestCase

  setup do
    @provider = FactoryBot.create(:simple_provider)
  end

  test '#access_tokens returns the user access tokens' do
    user = FactoryBot.create(:admin, account: @provider)
    token = FactoryBot.create(:access_token, owner: user)
    other_token = FactoryBot.create(:access_token)

    presenter = Provider::Admin::User::AccessTokensIndexPresenter.new(user: user)

    access_tokens = presenter.access_tokens
    assert_includes access_tokens, token
    assert_not_includes access_tokens, other_token
  end

  test '#no_allowed_scopes? is true when user has no permissions' do
    member = FactoryBot.create(:simple_user, account: @provider)

    presenter = Provider::Admin::User::AccessTokensIndexPresenter.new(user: member)

    assert presenter.no_allowed_scopes?
  end

  test '#no_allowed_scopes? is false when user has relevant permissions' do
    user = FactoryBot.create(:simple_user, account: @provider)
    user.stubs(:allowed_access_token_scopes).returns(
      AccessToken::ScopesFactory.build('Analytics API' => 'stats')
    )

    presenter = Provider::Admin::User::AccessTokensIndexPresenter.new(user: user)

    assert_not presenter.no_allowed_scopes?
  end

  test '#service_tokens returns services with tokens for authorized users' do
    admin = FactoryBot.create(:admin, account: @provider)
    token = FactoryBot.create(:simple_service, account: @provider).active_service_token

    presenter = Provider::Admin::User::AccessTokensIndexPresenter.new(user: admin)

    assert_includes presenter.service_tokens.map(&:active_service_token), token
  end

  test '#service_tokens returns empty for users without plans permission' do
    member = FactoryBot.create(:simple_user, account: @provider)
    member.stubs(:has_permission?).with(:plans).returns(false)

    presenter = Provider::Admin::User::AccessTokensIndexPresenter.new(user: member)

    assert_empty presenter.service_tokens
  end
end
