# frozen_string_literal: true

class Provider::Admin::Account::DataExportsController < Provider::Admin::Account::BaseController
  before_action :authorize_data_export
  before_action :set_selects_collections, only: :new

  activate_menu :account, :export

  EXPORTS_LABELS = {
    users: I18n.t('provider.admin.account.data_exports.labels.users'),
    applications: I18n.t('provider.admin.account.data_exports.labels.applications'),
    invoices: I18n.t('provider.admin.account.data_exports.labels.invoices'),
    messages: I18n.t('provider.admin.account.data_exports.labels.messages')
  }.freeze

  def new; end

  def create
    recipient = current_user
    DataExportsWorker.perform_async(current_account.id,
                                    recipient.id,
                                    permitted_params[:data],
                                    permitted_params[:period])

    flash.now[:success] = t('.success', email: recipient.email)
    respond_to do |format|
      format.js { render template: 'shared/_flash_alerts' }
    end
  end

  protected

  def authorize_data_export
    authorize! :export, :data
  end

  def set_selects_collections
    @targets = EXPORTS_LABELS.except(current_account.settings.finance.allowed? ? nil : :invoices).map(&:reverse)

    @periods = [[t('provider.admin.account.data_exports.periods.all'), ''],
                [t('provider.admin.account.data_exports.periods.today'), 'today'],
                [t('provider.admin.account.data_exports.periods.this_week'), 'this_week'],
                [t('provider.admin.account.data_exports.periods.this_month'), 'this_month'],
                [t('provider.admin.account.data_exports.periods.this_year'), 'this_year'],
                [t('provider.admin.account.data_exports.periods.last_year'), 'last_year']]
  end

  def permitted_params
    params.fetch(:export).permit(:data, :period)
  end
end
