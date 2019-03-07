# frozen_string_literal: true

require 'test_helper'

class Switches::CollectionTest < ActiveSupport::TestCase
  setup do
    @provider = FactoryBot.create(:provider_account)
    @switches = ::Switches::Collection.new(@provider.settings)
  end

  test 'holds a list of switches' do
    assert_same_elements ::Switches::SWITCHES, @switches.keys
    @switches.each { |_, switch| assert_kind_of ::Switches::Switch, switch }
  end

  test 'slices keys like a hash' do
    selected_keys = %i[account_plans multiple_users]
    assert_same_elements selected_keys, @switches.slice(*selected_keys).keys
  end

  test 'excepts keys like a hash' do
    excepted_keys = %i[account_plans multiple_users]
    remaining_keys = @switches.keys - excepted_keys
    assert_same_elements remaining_keys, @switches.except(*excepted_keys).keys
  end

  test 'selects values like a hash' do
    selected_keys = %i[multiple_services multiple_applications multiple_users]
    assert_same_elements selected_keys, @switches.select { |switch_name, _| switch_name.to_s.start_with?('multiple_') }.keys
  end

  test 'deletes a key like a hash' do
    assert_includes @switches.keys, :account_plans
    @switches.delete(:account_plans)
    assert_not_includes @switches.keys, :account_plans
  end

  test 'allowed' do
    assert_empty @switches.allowed.keys
    @provider.settings.allow_account_plans!
    @switches.reload
    assert_equal [:account_plans], @switches.allowed.keys
    @provider.settings.deny_account_plans!
    @switches.reload
    assert_empty @switches.allowed.keys
  end

  test 'denied' do
    denied_keys = @switches.switches.select { |_, switch| switch.denied? }.keys
    assert_same_elements denied_keys, @switches.denied.keys
    @provider.settings.send("allow_#{denied_keys.shift}!")
    @switches.reload
    assert_same_elements denied_keys, @switches.denied.keys
  end

  test 'hideable' do
    hideable_keys = @switches.switches.select { |_, switch| switch.hideable? }.keys
    assert_same_elements hideable_keys, @switches.hideable.keys
  end
end
