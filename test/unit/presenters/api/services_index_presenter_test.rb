# frozen_string_literal: true

require 'test_helper'

class Api::ServicesIndexPresenterTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @provider = FactoryBot.create(:simple_provider)
    @user = FactoryBot.create(:simple_user, account: @provider)
  end

  attr_reader :provider, :user

  test "20 products per page by default" do
    FactoryBot.create_list(:simple_service, 30, account: provider)
    presenter = Api::ServicesIndexPresenter.new(current_user: user, params: {})

    assert_equal 20, presenter.products.size
  end

  test "filter products by query" do
    ThinkingSphinx::Test.rt_run do
      perform_enqueued_jobs(only: SphinxIndexationWorker) do
        FactoryBot.create(:simple_service, name: 'Pepe API', account: provider)
        FactoryBot.create(:simple_service, name: 'Pepa API', account: provider)
      end

      assert_equal 2, Api::ServicesIndexPresenter.new(current_user: user, params: { search: {} }).products.size
      assert_equal 2, Api::ServicesIndexPresenter.new(current_user: user, params: { search: { query: 'api' } }).products.size
      assert_equal 1, Api::ServicesIndexPresenter.new(current_user: user, params: { search: { query: 'pepe' } }).products.size
      assert_equal 0, Api::ServicesIndexPresenter.new(current_user: user, params: { search: { query: 'asdf' } }).products.size
    end
  end

  test "paginate products" do
    FactoryBot.create_list(:simple_service, 10, account: provider)
    presenter = Api::ServicesIndexPresenter.new(current_user: user, params: { page: 1, per_page: 5 })
    assert_equal 5, presenter.products.size
  end

  test '#data includes the data for the index page' do
    presenter = Api::ServicesIndexPresenter.new(current_user: user, params: {})

    data = presenter.data
    assert data.key? :'new-product-path'
    assert data.key? :products
    assert data.key? :'products-count'
  end

  test '#dashboard_widget_data includes the data for the Dashboard widget' do
    presenter = Api::ServicesIndexPresenter.new(current_user: user, params: {})

    data = presenter.dashboard_widget_data
    assert data.key? :products
    assert data.key? :newProductPath
    assert data.key? :productsPath
  end

  test '#render_json includes total entries' do
    FactoryBot.create_list(:simple_service, 10, account: provider)
    presenter = Api::ServicesIndexPresenter.new(current_user: user, params: { per_page: 5 })

    result = presenter.render_json
    assert_equal 5, JSON.parse(result[:items]).count
    assert_equal 10, result[:count]
  end
end
