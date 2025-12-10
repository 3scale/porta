# frozen_string_literal: true

require 'test_helper'

class DashboardPresenterTest < ActiveSupport::TestCase
  def setup
    provider = FactoryBot.create(:simple_provider)
    user = FactoryBot.create(:admin, account: provider)

    @presenter = Provider::Admin::Dashboards::DashboardPresenter.new(user: user)
  end

  attr_reader :presenter

  test '#products_widget_data includes the data for the Dashboard widget' do
    data = presenter.products_widget_data
    assert data.key? :products
    assert data.key? :newProductPath
    assert data.key? :productsPath
  end

  test '#backends_widget_data includes the data for the Dashboard widget' do
    data = presenter.backends_widget_data
    assert data.key? :backends
    assert data.key? :newBackendPath
    assert data.key? :backendsPath
  end
end
