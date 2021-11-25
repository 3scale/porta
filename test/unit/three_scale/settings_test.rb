# frozen_string_literal: true

require 'test_helper'

class ThreeScale::SettingsTest < ActiveSupport::TestCase
  test 'configure' do
    key = "my.setting-#{random_suffix}"
    ThreeScale::Settings.configure(key) { 'value' }
    assert_equal 'value', ThreeScale::Settings.get(key)
  end

  test 'missing key' do
    assert_raises(KeyError) { ThreeScale::Settings.get("missing-setting-#{random_suffix}") }
  end

  test 'merge' do
    key = "my.setting-#{random_suffix}"
    refute ThreeScale::Settings.key?(key.to_sym)
    ThreeScale::Settings.merge!(key => 'value')
    assert_equal 'value', ThreeScale::Settings.get(key)
  end

  private

  # to avoid conflicts with other tests
  def random_suffix
    SecureRandom.hex(6)
  end
end
