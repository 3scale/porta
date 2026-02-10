# frozen_string_literal: true

class Buyers::InvoicesIndexPresenter
  include ::Draper::ViewHelpers
  include System::UrlHelpers.system_url_helpers

  def initialize(account:, current_account:, params: {})
    @account = account
    @is_provider = current_account.provider?
    @sort_params = [
      params.fetch(:sort, :id),
      params.fetch(:direction, :desc)
    ]
    @pagination_params = {
      page: params.fetch(:page, 1),
      per_page: params.fetch(:per_page, 20)
    }
  end

  attr_reader :account, :is_provider, :sort_params, :pagination_params

  def invoices
    @invoices ||= account.invoices
                         .includes(:provider_account)
                         .ordered
                         .order_by(*sort_params)
                         .paginate(pagination_params)
  end

  def link_to_invoice(invoice)
    path = invoice_path_for(invoice)
    friendly_id = invoice.friendly_id
    h.link_to friendly_id, path, title: "Show #{friendly_id}"
  end

  def invoices_path
    admin_buyers_account_invoices_path(account)
  end

  def toolbar_props
    create_button = {
      label: I18n.t('buyers.invoices.toolbar.primary'),
      variant: :primary,
    }

    if account.current_invoice
      create_button['data-disabled'] = I18n.t('buyers.invoices.create.open_invoice', name: account.name)
    else
      create_button['href'] = invoices_path
    end

    {
      actions: [create_button],
      totalEntries: invoices.total_entries
    }
  end

  def empty_state?
    invoices.empty?
  end

  private

  # This method smells of :reek:ControlParameter but it's OK
  def invoice_path_for(invoice)
    return admin_account_invoice_path(invoice) unless is_provider && account

    admin_buyers_account_invoice_path(account, invoice)
  end
end
