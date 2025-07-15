# frozen_string_literal: true

class Finance::Provider::InvoicesIndexPresenter
  include System::UrlHelpers.system_url_helpers
  include Finance::InvoicesHelper

  delegate :can?, to: :ability

  def initialize(provider:, user:, params:)
    @provider = provider
    @search = ThreeScale::Search.new(params[:search] || params)
    @sort_params = [params[:sort], params[:direction]]
    @pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
    @ability = Ability.new(user)
  end

  attr_reader :provider, :search, :sort_params, :pagination_params, :ability

  def empty_state?
    raw_invoices.empty?
  end

  def empty_search?
    searched_invoices.empty?
  end

  def searched_invoices
    @searched_invoices ||= raw_invoices.scope_search(search)
  end

  def invoices
    @invoices ||= searched_invoices.order_by(*sort_params)
                                   .paginate(pagination_params)
                                   .decorate
  end

  def years
    @years ||= years_by_provider(provider)
  end

  def toolbar_props
    props = {
      totalEntries: invoices.total_entries,
      overflow: [],
      attributeFilters: [{
        name: 'search[number]',
        title: 'Number',
        placeholder: '2017-06-* / 2018-*',
        chip: search.number
      }, {
        name: 'search[buyer_query]',
        title: 'Account',
        placeholder: '',
        chip: search.buyer_query
      }, {
        name: 'search[month_number]',
        title: 'Month',
        collection: months_for_filter,
        placeholder: 'Filter by month',
        chip: I18n.t('date.month_names')[search.month_number.to_i]
      }, {
        name: 'search[year]',
        title: 'Year',
        collection: years_for_filter,
        placeholder: 'Filter by year',
        chip: search.year
      }, {
        name: 'search[state]',
        title: 'State',
        collection: states_for_filter,
        placeholder: 'Filter by state',
        chip: search.state&.capitalize
      }]
    }

    if can?(:export, :data)
      props[:overflow].append({ href: new_provider_admin_account_data_exports_path,
                                label: 'Export to CSV',
                                isShared: false,
                                variant: :secondary })
    end

    props
  end

  private

  def raw_invoices
    @raw_invoices ||= provider.buyer_invoices.includes(:provider_account)
  end

  def states_for_filter
    Invoice.state_machine.states.keys.collect(&:to_s).sort.map do |state|
      { id: state, title: state.capitalize }
    end
  end

  def months_for_filter
    I18n.t('date.month_names').drop(1).map.with_index(1) do |month, i| # First item in array is nil
      { id: i, title: month }
    end
  end

  def years_for_filter
    years.map do |year|
      { id: year, title: year.to_s }
    end
  end
end
