# frozen_string_literal: true

require 'test_helper'

class Buyers::AccountsIndexPresenterTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @provider = FactoryBot.create(:simple_provider)
  end

  attr_reader :provider

  test "20 buyers per page by default" do
    FactoryBot.create_list(:simple_buyer, 30, provider_account: provider)
    presenter = Buyers::AccountsIndexPresenter.new(provider: provider, params: {})

    assert_equal 20, presenter.buyers.size
  end

  test "filter buyers by query" do
    ThinkingSphinx::Test.rt_run do
      perform_enqueued_jobs(only: SphinxAccountIndexationWorker) do
        FactoryBot.create(:simple_buyer, name: 'Pepe Account', provider_account: provider)
        FactoryBot.create(:simple_buyer, name: 'Pepa Account', provider_account: provider)
      end

      assert_equal 2, Buyers::AccountsIndexPresenter.new(provider: provider, params: { search: {} }).buyers.size
      assert_equal 2, Buyers::AccountsIndexPresenter.new(provider: provider, params: { search: { query: 'account' } }).buyers.size
      assert_equal 1, Buyers::AccountsIndexPresenter.new(provider: provider, params: { search: { query: 'pepe' } }).buyers.size
      assert_equal 0, Buyers::AccountsIndexPresenter.new(provider: provider, params: { search: { query: 'asdf' } }).buyers.size
    end
  end

  test "paginate buyers" do
    FactoryBot.create_list(:simple_buyer, 10, provider_account: provider)
    presenter = Buyers::AccountsIndexPresenter.new(provider: provider, params: { page: 1, per_page: 5 })
    assert_equal 5, presenter.buyers.size
  end

  test '#render_json includes total entries' do
    FactoryBot.create_list(:simple_buyer, 10, provider_account: provider)
    presenter = Buyers::AccountsIndexPresenter.new(provider: provider, params: { per_page: 5 })

    result = presenter.render_json
    assert_equal 5, JSON.parse(result[:items]).count
    assert_equal 10, result[:count]
  end
end
