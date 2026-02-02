# frozen_string_literal: true

class Finance::Provider::InvoicesController < Finance::Provider::BaseController
  include ThreeScale::Search::Helpers

  activate_menu :audience, :finance, :invoices

  helper Finance::InvoicesHelper
  helper_method :presenter

  before_action :find_buyer, only: :create
  before_action :find_invoice, except: %i[index create]

  delegate :referrer, to: :request

  attr_reader :presenter

  def index
    @presenter = Finance::Provider::InvoicesIndexPresenter.new(provider: current_account,
                                                               params: params,
                                                               user: current_user)
  end

  def show
    unless @invoice
      render_error t('.not_found'), status: :not_found
      return false
    end

    respond_to do |format|
      format.html
      format.json { render json: @invoice.to_json }
      format.js   { render json: @invoice.to_json }
      format.pdf  { redirect_to @invoice.pdf.url }
    end
  end

  def edit
    return if @invoice.editable?

    redirect_to admin_finance_invoice_url(@invoice), danger: t('.non_editable')
  end

  def create
    current_account.billing_strategy.create_invoice!(buyer_account: @buyer,
                                                     period: Month.new(Time.now.utc))
    respond_to do |format|
      format.js { flash.now[:success] = t('.success') }
    end
  end

  [ [:pay          ],
    [:generate_pdf ],
    [:cancel       ],
    [:issue        ],
    [:charge, false]
  ].each do |action, *opts|
    define_method(action) do
      invoice_action(action, *opts)
    end
  end

  def update
    if @invoice.update(params[:invoice])
      redirect_to admin_finance_invoice_url(@invoice), success: t('.success')
    else
      render :edit
    end
  end

  private

  # Called via invoice_action_button from:
  #  - buyers/invoices/show
  #  - finance/provider/invoices/show
  def invoice_action(action, *action_params)
    if @invoice.transition_allowed?(action) && @invoice.send("#{action}!", *action_params)
      redirect_to referrer, success: t('.success')
    else
      redirect_to referrer, danger: t('.error')
    end
  end

  def collection
    @collection ||= if params[:account_id]
                      find_buyer.invoices
                    else
                      current_account.buyer_invoices.includes(:provider_account)
                    end
  end

  def find_buyer(options = {})
    @buyer ||= current_account.buyer_accounts.where(options).find(params[:account_id])
  end

  def find_invoice
    @invoice = collection.find(params[:id])
  end
end
