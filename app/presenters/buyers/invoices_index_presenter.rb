# frozen_string_literal: true

class Buyers::InvoicesIndexPresenter
  include ::Draper::ViewHelpers
  include System::UrlHelpers.system_url_helpers

  def initialize(account:, user:, params:)
    @account = account
    @sort_params = [params[:sort] || 'id', params[:direction] || 'desc']
    @pagination_params = { page: params[:page] || 1, per_page: params[:per_page] || 20 }
    @user = user
  end

  attr_reader :account, :sort_params, :pagination_params, :user

  def invoices
    @invoices ||= raw_invoices.order_by(*sort_params)
                              .paginate(pagination_params)
  end

  # This method smells of :reek:ControlParameter but it's OK
  def link_to_invoice(invoice, is_provider:)
    path = if is_provider && account
             admin_buyers_account_invoice_path(account, invoice)
           else
             admin_account_invoice_path(invoice)
           end

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

  def raw_invoices
    @raw_invoices ||= account.invoices.includes(:provider_account)
                                      .ordered
  end
end
