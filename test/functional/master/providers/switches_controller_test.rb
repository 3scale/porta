require 'test_helper'

class Master::Providers::SwitchesControllerTest < ActionDispatch::IntegrationTest

  setup do
    master = Account.master rescue FactoryBot.create(:simple_master)
    provider_login FactoryBot.create(:simple_user, account: master, state: 'active')
  end

  test 'should return 404 in case of wrong switch' do
    put master_provider_switch_path(provider.id, 'unknown')
    assert_response :not_found
  end

  test 'should enable the switch when denied' do
    switch = settings.switches.fetch(:web_hooks)
    assert switch.denied?

    put master_provider_switch_path(provider.id, 'web_hooks')
    assert_response :found

    assert switch.reload.allowed?
  end

  test 'should disable the switch when hidden' do
    switch = settings.switches.fetch(:finance)
    assert switch.allow

    delete master_provider_switch_path(provider.id, switch.name)
    assert_response :found

    assert switch.reload.denied?
  end

  test 'should disable the switch when visible' do
    rolling_updates_off
    provider.settings.allow_multiple_users!

    delete master_provider_switch_path(provider.id, 'multiple_users')
    assert_response :found
  end

  test 'should not change when the same' do
    switch = allowed_switch(:end_users)
    put master_provider_switch_path(provider.id, switch.name)
    assert_response :not_modified
  end

  test 'should require current user' do
    logout!
    switch = settings.switches.fetch(:end_users)

    delete master_provider_switch_path(provider.id, switch.name)
    assert_response :forbidden
  end

  # @return [Account]
  def provider
    @_provider ||= FactoryBot.create(:simple_provider)
  end

  def allowed_switch(name)
    switch = settings.switches.fetch(name)
    assert switch.allow && switch.show!
    switch
  end

  delegate :settings, to: :provider
end
