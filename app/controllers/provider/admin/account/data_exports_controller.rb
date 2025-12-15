# frozen_string_literal: true

class Provider::Admin::Account::DataExportsController < Provider::Admin::Account::BaseController
  before_action :authorize_data_export
  before_action :set_selects_collections, only: :new

  activate_menu :account, :export

  TYPES = {
    users: I18n.t('provider.admin.account.data_exports.labels.users'),
    applications: I18n.t('provider.admin.account.data_exports.labels.applications'),
    invoices: I18n.t('provider.admin.account.data_exports.labels.invoices'),
    messages: I18n.t('provider.admin.account.data_exports.labels.messages')
  }.freeze

  PERIODS = {
    all: I18n.t('provider.admin.account.data_exports.periods.all'),
    today: I18n.t('provider.admin.account.data_exports.periods.today'),
    this_week: I18n.t('provider.admin.account.data_exports.periods.this_week'),
    this_month: I18n.t('provider.admin.account.data_exports.periods.this_month'),
    this_year: I18n.t('provider.admin.account.data_exports.periods.this_year'),
    last_year: I18n.t('provider.admin.account.data_exports.periods.last_year')
  }.freeze

  def new; end

  def create
    if valid_params?
      DataExportsWorker.perform_async(current_account.id,
                                      current_user.id,
                                      data,
                                      period)

      flash.now[:success] = t('.success', email: current_user.email)
    end

    respond_to do |format|
      format.js { render template: 'shared/_flash_alerts' }
    end
  end

  protected

  def authorize_data_export
    authorize! :export, :data
  end

  def set_selects_collections
    @targets = permitted_types.map(&:reverse)
    @periods = PERIODS.map(&:reverse)
  end

  def valid_params?
    if permitted_types.keys.exclude?(data.to_sym)
      flash.now[:danger] = t('.invalid_data')
      false
    elsif PERIODS.keys.exclude?(period.to_sym)
      flash.now[:danger] = t('.invalid_period')
      false
    else
      true
    end
  end

  def data
    @data ||= params.require(:export).require(:data)
  end

  def period
    @period ||= params.require(:export).require(:period)
  end

  def permitted_types
    @permitted_types ||= TYPES.except(current_account.settings.finance.allowed? ? nil : :invoices)
  end
end
