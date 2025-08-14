# frozen_string_literal: true

class Sites::EmailsController < Sites::BaseController
  include System::UrlHelpers.system_url_helpers

  provider_required

  before_action :find_account
  before_action :find_exceptions, only: :edit
  prepend_before_action :deny_on_premises_for_master

  helper_method :props, :popover_props, :exceptions, :products_with_default_email

  activate_menu :audience, :messages, :email

  def edit; end

  def update
    account_saved = update_account
    services_saved = update_services

    if account_saved && services_saved
      flash[:success] = t('.success')
      redirect_to action: :edit
    else
      flash.now[:warning] = t('.warning')
      render :edit
    end
  end

  private

  def presenter
    @presenter ||= Api::ServicesIndexPresenter.new(user: current_user)
  end

  def update_account
    account_params = params.require(:account).permit(%i[support_email finance_support_email services])

    @account.update(account_params)
  end

  def update_services # rubocop:disable Metrics/AbcSize
    service_params = params.require(:account).permit(services: :support_email)
    services_valid = true

    ids = service_params[:services].keys.map(&:to_i)
    @exceptions = current_user.accessible_services.where(id: ids)

    service_params[:services].each do |key, hash|
      index = @exceptions.index { |item| item.id == key.to_i }
      new_email = hash[:support_email].presence # Blank inputs ('') will be removed by setting nil

      # Need to do this in 2 different lines or #update doesn't work
      valid = @exceptions[index].update(support_email: new_email)
      services_valid &&= valid
    end

    valid
  end

  def find_account
    @account = current_account
  end

  def find_exceptions
    @exceptions = presenter.products.where.not(support_email: nil)
  end

  def products_with_default_email
    @products_with_default_email ||= presenter.products.where(support_email: nil)
  end

  def props
    products = products_with_default_email.decorate
    total_entries = products.total_entries

    {
      initialProducts: products.as_json(only: %i[id name system_name updated_at], js: true),
      productsCount: total_entries,
      buttonLabel: t('sites.emails.edit.add_exception'),
      productsPath: total_entries > 20 ? admin_services_path : nil
    }
  end

  def popover_props
    { body: t('sites.emails.edit.popover') }
  end
end
