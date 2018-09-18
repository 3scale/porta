# frozen_string_literal: true

class Finance::Provider::LineItemsController < FrontendController
  activate_menu :finance
  before_action :find_invoice
  before_action :find_line_item, :only => :destroy
  layout false

  def new
    @line_item = @invoice.line_items.build

    respond_to do |format|
      format.html
      format.js { render :layout => false, :content_type => :html }
    end
  end

  def create
    @line_item = billing.create_line_item(line_item_params)
    if @line_item.persisted?
      render_template_success
    else
      render_template_error
    end
  end

  def destroy
    if billing.destroy_line_item(@line_item)
      render_template_success
    else
      render_template_error
    end
  end

  private

  def render_template_success
    respond_to do |format|
      format.html { redirect_to(admin_finance_account_invoice_url(@buyer, @invoice)) }
      format.js
    end
  end

  def render_template_error
    respond_to do |format|
      format.html { redirect_to(admin_finance_account_invoice_url(@buyer, @invoice), flash: { error: @line_item.errors.full_messages.join(', ') }) }
      format.js { render 'finance/provider/line_items/errors' }
    end
  end

  def billing
    @billing ||= Finance::AdminBilling.new(find_invoice)
  end

  def find_invoice
    @invoice ||= find_buyer.invoices.find(params[:invoice_id])
  end

  def find_buyer
    @buyer ||= current_account.buyer_accounts.find(params[:account_id])
  end

  def find_line_item
    @line_item = @invoice.line_items.find(params[:id])
  end

  def line_item_params
    params.require(:line_item).permit(:name, :description, :quantity, :cost)
  end
end
