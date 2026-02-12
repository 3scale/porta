# frozen_string_literal: true

require 'test_helper'

# Ignore :reek:InstanceVariableAssumption
class Buyers::InvoicesIndexPresenterTest < ActiveSupport::TestCase
  def setup
    @buyer = FactoryBot.create(:buyer_account)
    @provider_account = @buyer.provider_account
  end

  attr_reader :buyer, :provider_account

  alias current_account provider_account

  test 'initialize with default params' do
    presenter = Buyers::InvoicesIndexPresenter.new(buyer:)

    assert_equal %i[id desc], presenter.sort_params
    assert_equal({ page: 1, per_page: 20 }, presenter.pagination_params)
  end

  test 'initialize with custom sort and pagination params' do
    params = { sort: 'state', direction: 'asc', page: 2, per_page: 10 }
    presenter = Buyers::InvoicesIndexPresenter.new(buyer:, params:)

    assert_equal %w[state asc], presenter.sort_params
    assert_equal({ page: 2, per_page: 10 }, presenter.pagination_params)
  end

  test 'invoices returns paginated and sorted invoices' do
    FactoryBot.create_list(:invoice, 25, buyer_account: buyer, provider_account:)
    presenter = Buyers::InvoicesIndexPresenter.new(buyer:)

    assert_equal 20, presenter.invoices.size
  end

  test 'empty_state? returns true when no invoices' do
    presenter = Buyers::InvoicesIndexPresenter.new(buyer:)

    assert_empty buyer.invoices
    assert presenter.empty_state?
  end

  test 'empty_state? returns false when invoices exist' do
    FactoryBot.create(:invoice, buyer_account: buyer, provider_account:)
    presenter = Buyers::InvoicesIndexPresenter.new(buyer:)

    assert_not_empty buyer.invoices
    assert_not presenter.empty_state?
  end

  test 'toolbar_props includes create button with href when no current invoice' do
    presenter = Buyers::InvoicesIndexPresenter.new(buyer:)
    button_props = presenter.toolbar_props[:actions][0]

    assert_equal "/buyers/accounts/#{buyer.id}/invoices", button_props['href']
    assert_not button_props['data-disabled']
  end

  test 'toolbar_props includes disabled button when current invoice exists' do
    FactoryBot.create(:invoice, buyer_account: buyer, provider_account:, state: 'open')
    buyer.reload

    presenter = Buyers::InvoicesIndexPresenter.new(buyer:)
    button_props = presenter.toolbar_props[:actions][0]

    assert_not button_props.key?('href')
    assert_match(/already has an open invoice/, button_props['data-disabled'])
  end
end
