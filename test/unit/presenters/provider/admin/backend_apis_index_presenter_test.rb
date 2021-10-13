# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::BackendApisIndexPresenterTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @provider = FactoryBot.create(:simple_provider)
  end

  attr_reader :provider, :user

  test "20 backend apis per page by default" do
    FactoryBot.create_list(:backend_api, 30, account: provider)
    presenter = Provider::Admin::BackendApisIndexPresenter.new(current_account: provider, params: {})

    assert_equal 20, presenter.backend_apis.size
  end

  test "filter backend_apis by query" do
    ThinkingSphinx::Test.rt_run do
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        FactoryBot.create(:backend_api, name: 'Pepe API', account: provider)
        FactoryBot.create(:backend_api, name: 'Pepa API', account: provider)
      end

      assert_equal 2, Provider::Admin::BackendApisIndexPresenter.new(current_account: provider, params: { search: {} }).backend_apis.size
      assert_equal 2, Provider::Admin::BackendApisIndexPresenter.new(current_account: provider, params: { search: { query: 'api' } }).backend_apis.size
      assert_equal 1, Provider::Admin::BackendApisIndexPresenter.new(current_account: provider, params: { search: { query: 'pepe' } }).backend_apis.size
      assert_equal 0, Provider::Admin::BackendApisIndexPresenter.new(current_account: provider, params: { search: { query: 'asdf' } }).backend_apis.size
    end
  end

  test "paginate backend_apis" do
    FactoryBot.create_list(:backend_api, 10, account: provider)
    presenter = Provider::Admin::BackendApisIndexPresenter.new(current_account: provider, params: { page: 1, per_page: 5 })
    assert_equal 5, presenter.backend_apis.size
  end

  test '#data includes the data for the index page' do
    presenter = Provider::Admin::BackendApisIndexPresenter.new(current_account: provider, params: {})

    data = presenter.data
    assert data.key? :'new-backend-path'
    assert data.key? :backends
    assert data.key? :'backends-count'
  end

  test '#dashboard_widget_data includes the data for the Dashboard widget' do
    presenter = Provider::Admin::BackendApisIndexPresenter.new(current_account: provider, params: {})

    data = presenter.dashboard_widget_data
    assert data.key? :backends
    assert data.key? :newBackendPath
    assert data.key? :backendsPath
  end
end
