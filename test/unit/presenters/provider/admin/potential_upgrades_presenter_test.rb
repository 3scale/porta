# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::PotentialUpgradesPresenterTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include DashboardTimeRange

  def setup
    @provider = FactoryBot.build_stubbed(:buyer_account)
    @user = FactoryBot.build_stubbed(:admin, account: provider)
  end

  attr_reader :provider, :user

  test '#dashboard_widget_data includes the data for the Dashboard widget' do
    presenter = Provider::Admin::PotentialUpgradesPresenter.new(current_account: provider, current_user: user)

    data = presenter.dashboard_widget_data
    assert data.key?(:violations)
    assert data.key?(:incorrectSetUp)
    assert data.key?(:links)
    assert data[:links].key?(:adminServiceApplicationPlans)
    assert data[:links].key?(:settingsAdminService)
  end

  test '#dashboard_widget_data calls UsageLimitViolationsQuery with the correct arguments' do
    usage_limit_violations_query = UsageLimitViolationsQuery.new(provider)

    UsageLimitViolationsQuery.expects(:new).with(provider).at_least_once.returns(usage_limit_violations_query)
    usage_limit_violations_query.expects(:in_range).with(current_range).at_least_once.returns(Alert.none)

    Provider::Admin::PotentialUpgradesPresenter.new(
      current_account: provider, current_user: user
    ).dashboard_widget_data
  end
end
