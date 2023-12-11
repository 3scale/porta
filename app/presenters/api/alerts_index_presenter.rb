# frozen_string_literal: true

class Api::AlertsIndexPresenter
  include ::Draper::ViewHelpers

  def initialize(raw_alerts:, params:, service:, current_account:)
    @raw_alerts = raw_alerts
    @service = service

    @pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
    @sorting_params = [params[:sort], params[:direction]]
    @search = new_search(params, current_account)
  end

  attr_reader :raw_alerts, :service, :pagination_params, :sorting_params, :search

  delegate :total_entries, to: :alerts

  def alerts
    @alerts ||= raw_alerts.order_by(*sorting_params)
                          .scope_search(search)
                          .paginate(pagination_params)
  end

  def empty_state?
    raw_alerts.empty?
  end

  def empty_search?
    alerts.empty?
  end

  def toolbar_props # rubocop:disable Metrics/MethodLength
    {
      totalEntries: total_entries,
      actions: [],
      overflow: [{
        href: h.polymorphic_path([:all_read, :admin, service, :alerts]),
        label: t('.read_all_button.label'),
        variant: :primary,
        'data-method': :put,
        'data-confirm': t('.read_all_button.confirm'),
        isShared: true
      }, {
        href: h.polymorphic_path([:purge, :admin, service, :alerts]),
        label: t('.purge_button.label'),
        variant: :danger,
        'data-method': :delete,
        'data-confirm': t('.purge_button.confirm'),
        isShared: true
      }],
      search: {
        name: 'search[account][query]',
        placeholder: t('.search_placeholder')
      }
    }
  end

  def page_title
    service ? t('.page_title.service') : t('.page_title.all')
  end

  def link_to_account_for_alert(alert)
    if (account = alert.cinstance.try(:user_account))
      h.link_to account.org_name, h.admin_buyers_account_path(account)
    else
      h.tag.span('missing')
    end
  end

  private

  def new_search(params, current_account)
    # default to account_id and cinstance_id params if no search hash is passed
    search_params = params.fetch(:search) { params.slice(:account_id, :cinstance_id) }

    search = ThreeScale::Search.new(search_params)

    if (account = search.account.presence)
      # HACK: threescale/search would remove all blank entries including empty array. To prevent
      # that, pass -1 as id (which never exists) to return no results.
      search.account_id = current_account.buyers.scope_search(account).pluck(:id).presence || -1
    end

    search
  end

  def t(string, opts = {})
    I18n.t(string, opts.merge(scope: 'api.alerts.index'))
  end
end
