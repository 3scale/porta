# frozen_string_literal: true

class Buyers::AccountsIndexPresenter
  include System::UrlHelpers.system_url_helpers

  def initialize(provider:, user: nil, params: {})
    @provider = provider
    @pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
    @search = ThreeScale::Search.new(params[:search])
    @sorting_params = [params[:sort] || 'created_at', params[:direction] || 'desc']
    @ability = Ability.new(user)
  end

  attr_reader :provider, :pagination_params, :search, :sorting_params, :ability

  delegate :total_entries, to: :buyers
  delegate :can?, to: :ability

  def buyers
    @buyers ||= raw_buyers.scope_search(search)
                          .order_by(*sorting_params)
                          .paginate(pagination_params)
  end

  def account_plans
    @account_plans ||= provider.account_plans.stock
  end

  def account_plans_size
    @account_plans_size ||= account_plans.size
  end

  alias paginated_buyers buyers

  # The JSON response of index endpoint is used to populate NewApplicationForm's BuyerSelect
  def render_json
    {
      items: buyers.includes(:bought_service_contracts).map { |a| BuyerPresenter.new(a).new_application_data.as_json }.to_json,
      count: total_entries
    }
  end

  def empty_state?
    @raw_buyers.empty?
  end

  def empty_search_state?
    @buyers.empty?
  end

  def toolbar_props # rubocop:disable Metrics/MethodLength
    props = {
      totalEntries: total_entries,
      actions: [],
      overflow: [],
      search: {
        placeholder: 'Search an account'
      },
      filters: [{
        attribute: :state,
        collection: account_states_for_select,
        placeholder: 'State'
      }]
    }

    if can?(:create, Account)
      props[:actions].append({ href: create_account_path,
                               label: 'Add an account',
                               variant: :primary })
    end

    if account_plans_size > 1
      props[:filters].prepend({ attribute: :plan_id,
                                collection: account_plans.map do |plan|
                                  { id: plan.id.to_s, title: plan.name }
                                end,
                                placeholder: 'Plan' })
    end

    if can?(:export, :data)
      props[:overflow].append({ href: new_provider_admin_account_data_exports_path,
                                label: 'Export to CSV',
                                isShared: false,
                                variant: :secondary })
    end

    props
  end

  def accounts_path
    provider.master? ? provider_admin_accounts_path : admin_buyers_accounts_path
  end

  def create_account_path
    @create_account_path ||= provider.master? ? new_provider_admin_account_path : new_admin_buyers_account_path
  end

  private

  def raw_buyers
    @raw_buyers ||= provider.buyer_accounts
                            .includes([:admin_user])
                            .not_master
  end

  def account_states_for_select
    states = [
      { id: :approved, title: 'Approved' },
      { id: :created, title: 'Created'},
      { id: :pending, title: 'Pending' },
      { id: :rejected, title: 'Rejected' }
    ]

    states << { id: :suspended, title: 'Suspended' } if provider == Account.master
    states
  end
end
