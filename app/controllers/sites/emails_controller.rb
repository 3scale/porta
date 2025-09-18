# frozen_string_literal: true

class Sites::EmailsController < Sites::BaseController
  include System::UrlHelpers.system_url_helpers

  provider_required

  before_action :find_account
  prepend_before_action :deny_on_premises_for_master

  helper_method :props

  activate_menu :audience, :messages, :email

  def edit; end

  def update
    account_saved = update_account

    if account_saved
      flash[:success] = t('.success')
      redirect_to action: :edit
    else
      flash.now[:warning] = t('.warning')
      render :edit
    end
  end

  # TODO: move this somewhere else.
  def fetch_services
    data = {
      items: products_without_support_email.paginate(page: params[:page], per_page: params[:per_page])
                                           .decorate
                                           .to_json(only: %i[id name system_name updated_at], js: true),
      count: total_products_without_support_email
    }

    respond_to do |format|
      format.json { render json: data }
    end
  end

  private

  def update_account
    account_params = params.require(:account).permit(%i[support_email finance_support_email services])

    @account.update(account_params)
  end

  def find_account
    @account = current_account
  end

  def products
    @products ||= current_user.accessible_services
                              .order(name: :asc)
  end

  def products_without_support_email
    @products_without_support_email ||= products.where(support_email: nil)
  end

  def total_products_without_support_email
    @total_products_without_support_email ||= products_without_support_email.size
  end

  def exceptions
    @exceptions ||= products.where.not(support_email: nil)
  end

  def props
    {
      buttonLabel: total_products_without_support_email.positive? ? t('sites.emails.edit.add_exception') : nil,
      removeConfirmation: t('.remove_confirmation'),
      exceptions: exceptions.decorate.as_json(only: %i[id name system_name updated_at support_email], js: true),
      products: products_without_support_email.paginate(page: 1, per_page: 20).decorate.as_json(only: %i[id name system_name updated_at], js: true),
      productsCount: total_products_without_support_email,
      productsPath: total_products_without_support_email > 20 ? fetch_services_admin_site_emails_path : nil,
    }
  end
end
