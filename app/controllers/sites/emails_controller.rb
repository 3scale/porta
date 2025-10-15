# frozen_string_literal: true

class Sites::EmailsController < Sites::BaseController
  include System::UrlHelpers.system_url_helpers

  provider_required

  prepend_before_action :deny_on_premises_for_master

  helper_method :props

  activate_menu :audience, :messages, :email

  def edit; end

  def update
    account_params = params.require(:account).permit(%i[support_email finance_support_email])

    if current_account.update(account_params)
      redirect_to({ action: :edit }, success: t('.success'))
    else
      flash.now[:error] = t('.error')
      render :edit
    end
  end

  private

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
      buttonLabel: t('sites.emails.edit.add_exception'),
      removeConfirmation: t('.remove_confirmation'),
      exceptions: exceptions.decorate.as_json(only: %i[id name system_name updated_at support_email], js: true),
      products: products_without_support_email.paginate(page: 1, per_page: 20).decorate.as_json(only: %i[id name system_name updated_at], js: true),
      productsCount: total_products_without_support_email,
      productsPath: url_for(controller: 'api/services', only_path: true),
    }
  end
end
