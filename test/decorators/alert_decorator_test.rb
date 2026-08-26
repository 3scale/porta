# frozen_string_literal: true

require 'test_helper'

class AlertDecoratorTest < Draper::TestCase

  test 'icon for each alert level' do
    expected_icons = {
      50 => 'fa-info-circle',
      80 => 'fa-exclamation-triangle',
      90 => 'fa-exclamation-triangle',
      100 => 'fa-exclamation-circle',
      120 => 'fa-exclamation-circle',
      150 => 'fa-exclamation-circle',
      200 => 'fa-exclamation-circle',
      300 => 'fa-exclamation-circle'
    }
    expected_icons.each do |level, icon|
      alert = FactoryBot.build(:alert, level: level)
      helpers.stubs(:utilization_range).returns(level)
      assert_match icon, AlertDecorator.decorate(alert).icon
    end
  end

  test 'link_to_app without cinstance' do
    alert = FactoryBot.build(:alert, cinstance: nil, account: FactoryBot.build(:account))
    assert_match '(deleted app)', AlertDecorator.decorate(alert).link_to_app
  end

  test 'link_to_app with cinstance' do
    alert = FactoryBot.build(:alert)
    helpers.stubs(:provider_admin_application_path).with(alert.cinstance).returns('/path/to/app')

    result = AlertDecorator.decorate(alert).link_to_app
    assert_match alert.cinstance.name, result
    assert_match '/path/to/app', result
  end
end
