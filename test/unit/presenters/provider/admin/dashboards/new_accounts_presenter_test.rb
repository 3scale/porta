# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::Dashboards::NewAccountsPresenterTest < Draper::TestCase
  def setup
    @current_data = {
      '2024-01-01' => 5,
      '2024-01-02' => 3,
      '2024-01-03' => 7
    }
    @previous_data = {
      '2023-12-29' => 4,
      '2023-12-30' => 2,
      '2023-12-31' => 6
    }
    @data = {
      new_accounts: @current_data,
      previous_accounts: @previous_data
    }
  end

  test 'calculates rest_days_signups correctly (excludes today)' do
    presenter = Provider::Admin::Dashboards::NewAccountsPresenter.new(@data.dup)

    assert_equal 8, presenter.rest_days_signups
  end

  test 'sets todays_sinups to today value' do
    presenter = Provider::Admin::Dashboards::NewAccountsPresenter.new(@data.dup)

    assert_equal 7, presenter.todays_signups
  end

  test 'generates correct chart_data' do
    presenter = Provider::Admin::Dashboards::NewAccountsPresenter.new(@data.dup)

    assert_equal 3, presenter.chart_data.length
    assert_equal '2024-01-01', presenter.chart_data[0][0]
    assert_equal '2024-01-02', presenter.chart_data[1][0]
    assert_equal '2024-01-03', presenter.chart_data[2][0]

    assert_kind_of String, presenter.chart_data[0][1]
  end

  test 'history? returns true when previous sum is positive' do
    presenter = Provider::Admin::Dashboards::NewAccountsPresenter.new(@data.dup)

    assert presenter.history?
  end

  test 'history? returns false when no old signups' do
    data = {
      new_accounts: @current_data,
      previous_accounts: {
        '2023-12-31' => 0
      }
    }
    presenter = Provider::Admin::Dashboards::NewAccountsPresenter.new(data)

    assert_not presenter.history?
  end

  test 'calculates percentage_change correctly' do
    presenter = Provider::Admin::Dashboards::NewAccountsPresenter.new(@data.dup)

    expected_percentage = ((8.0 - 12.0) / 12.0) * 100
    assert_in_delta expected_percentage, presenter.instance_variable_get(:@percentage_change), 0.01
  end

  test 'title_with_history formats percentage correctly' do
    presenter = Provider::Admin::Dashboards::NewAccountsPresenter.new(@data.dup)

    assert_match(/^[+-]\d+$/, presenter.title_with_history)
  end

  test 'handles single day current data' do
    data = {
      new_accounts: {
        '2024-01-01' => 5
      },
      previous_accounts: @previous_data
    }
    presenter = Provider::Admin::Dashboards::NewAccountsPresenter.new(data)

    assert_equal 0, presenter.rest_days_signups
    assert_equal 5, presenter.todays_signups
  end

  test 'handles empty current data' do
    data = {
      new_accounts: {},
      previous_accounts: @previous_data
    }

    assert_raises(NoMethodError) do
      Provider::Admin::Dashboards::NewAccountsPresenter.new(data)
    end
  end

  test 'handles zero previous sum in percentage calculation' do
    data = {
      new_accounts: @current_data,
      previous_accounts: {
        '2023-12-31' => 0
      }
    }
    presenter = Provider::Admin::Dashboards::NewAccountsPresenter.new(data)

    percentage_change = presenter.instance_variable_get(:@percentage_change)
    assert_equal 0, percentage_change
  end

  test 'id returns correct constant' do
    presenter = Provider::Admin::Dashboards::NewAccountsPresenter.new(@data.dup)

    assert_equal 'new-accounts-widget', presenter.id
  end
end
