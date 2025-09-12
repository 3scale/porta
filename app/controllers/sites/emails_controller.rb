# frozen_string_literal: true

class Sites::EmailsController < Sites::BaseController
  include System::UrlHelpers.system_url_helpers

  provider_required

  before_action :find_account
  prepend_before_action :deny_on_premises_for_master

  helper_method :props, :popover_props

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

  def update_account
    account_params = params.require(:account).permit(%i[support_email finance_support_email services])

    @account.update(account_params)
  end

  def update_services # rubocop:disable Metrics/AbcSize
    service_params = params.require(:account).permit(services: %i[support_email remove])
    services_valid = true
    return services_valid unless (services = service_params[:services].presence)

    ids = services.keys.map(&:to_i)
    exceptions = current_user.accessible_services.where(id: ids)

    services.each do |key, hash|
      exception = exceptions.find { |item| item.id == key.to_i }
      support_email = hash.key?(:remove) ? nil : hash[:support_email].presence
      valid = exception.update(support_email:)
      services_valid &&= valid
    end

    services_valid
  end

  def find_account
    @account = current_account
  end

  def products
    current_user.accessible_services
                .order(name: :asc)
                .paginate(page: 1, per_page: 20)
  end

  def props
    exceptions = products.where.not(support_email: nil)
                         .decorate
    products_without_support_email = products.where(support_email: nil)
                                             .decorate
    total_entries = products.total_entries

    {
      buttonLabel: products_without_support_email.size.positive? ? t('sites.emails.edit.add_exception') : nil,
      removeConfirmation: t('.remove_confirmation'),
      exceptions: exceptions.as_json(only: %i[id name system_name updated_at support_email], js: true),
      products: products_without_support_email.as_json(only: %i[id name system_name updated_at], js: true),
      productsCount: total_entries,
      productsPath: total_entries > 20 ? admin_services_path : nil,
    }
  end

  def popover_props
    { body: t('sites.emails.edit.popover') }
  end
end
