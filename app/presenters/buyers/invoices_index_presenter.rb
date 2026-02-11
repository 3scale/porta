# frozen_string_literal: true

class Buyers::InvoicesIndexPresenter
  include ::Draper::ViewHelpers
  include System::UrlHelpers.system_url_helpers

  # Ignore :reek:FeatureEnvy
  def initialize(buyer:, params: {})
    @buyer = buyer
    @sort_params = [
      params.fetch(:sort, :id),
      params.fetch(:direction, :desc)
    ]
    @pagination_params = {
      page: params.fetch(:page, 1),
      per_page: params.fetch(:per_page, 20)
    }
  end

  attr_reader :sort_params, :pagination_params

  def invoices
    # Eager load provider_account to prevent N+1 queries when invoice.cost is called.
    # Open/finalized invoices access provider.currency which requires the association.
    @invoices ||= @buyer.invoices
                        .includes(:provider_account)
                        .ordered
                        .order_by(*sort_params)
                        .paginate(pagination_params)
  end

  def link_to_invoice(invoice)
    friendly_id = invoice.friendly_id
    h.link_to friendly_id, admin_buyers_account_invoice_path(@buyer, invoice), title: "Show #{friendly_id}"
  end

  def invoices_path
    admin_buyers_account_invoices_path(@buyer)
  end

  def toolbar_props
    create_button = {
      label: I18n.t('buyers.invoices.toolbar.primary'),
      variant: :primary,
    }

    if @buyer.current_invoice
      create_button['data-disabled'] = I18n.t('buyers.invoices.create.open_invoice', name: @buyer.name)
    else
      create_button['href'] = invoices_path
      create_button['data-method'] = :post
    end

    {
      actions: [create_button],
      totalEntries: invoices.total_entries
    }
  end

  def empty_state?
    invoices.empty?
  end
end
