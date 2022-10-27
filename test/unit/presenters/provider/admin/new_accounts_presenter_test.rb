# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::NewAccountsPresenterTest < ActiveSupport::TestCase
  include DashboardTimeRange

  def setup
    @provider = FactoryBot.create(:account)
  end

  attr_reader :provider

  test '#dashboard_widget_data includes the data for the Dashboard widget' do
    presenter = Provider::Admin::NewAccountsPresenter.new(current_account: provider)

    data = presenter.dashboard_widget_data
    assert data.key?(:chartData)
    assert data[:chartData].key?(:values)
    assert data[:chartData].key?(:complete)
    assert data[:chartData].key?(:incomplete)
    assert data[:chartData].key?(:previous)
    assert data.key?(:newAccountsTotal)
    assert data.key?(:hasHistory)
    assert data.key?(:links)
    assert data[:links].key?(:previousRangeAdminBuyersAccount)
    assert data[:links][:previousRangeAdminBuyersAccount].key?(:url)
    assert data[:links][:previousRangeAdminBuyersAccount].key?(:value)
    assert data[:links].key?(:currentRangeAdminBuyersAccount)
    assert data[:links][:currentRangeAdminBuyersAccount].key?(:url)
    assert data[:links].key?(:lastDayInRangeAdminBuyersAccount)
    assert data[:links][:lastDayInRangeAdminBuyersAccount].key?(:url)
    assert data[:links][:lastDayInRangeAdminBuyersAccount].key?(:value)
    assert data.key?(:percentualChange)
  end

  test '#dashboard_widget_data calls NewAccountsQuery with the correct arguments' do
    travel_to Time.zone.local(2022, 01, 01) do
      new_accounts_query = NewAccountsQuery.new(provider)

      NewAccountsQuery.expects(:new).with(provider).at_least_once.returns(new_accounts_query)
      new_accounts_query.expects(:within_timeframe).with(range: current_range).at_least_once.returns({})
      new_accounts_query.expects(:within_timeframe).with(range: previous_range).at_least_once.returns({})

      Provider::Admin::NewAccountsPresenter.new(current_account: provider).dashboard_widget_data
    end
  end
end
