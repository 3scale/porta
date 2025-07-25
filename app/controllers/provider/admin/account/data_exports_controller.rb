class Provider::Admin::Account::DataExportsController < Provider::Admin::Account::BaseController
  before_action :authorize_data_export
  before_action :set_selects_collections,         :only => :new
  before_action :redirect_to_new_on_invalid_data, :only => :create

  activate_menu :account, :export

  EXPORTS_LABELS = {
    users: 'Accounts & Admin',
    applications: 'Applications',
    invoices: 'Invoices',
    messages: 'Messages'
  }.freeze

  EXPORTS_TARGETS = EXPORTS_LABELS.keys.map(&:to_s).freeze

  def new
  end

  def create
    recipient = current_user
    DataExportsWorker.perform_async(current_account.id,
                                    recipient.id,
                                    permitted_params[:data],
                                    permitted_params[:period])
    redirect_to({ action: :new }, success: t('.success', email: recipient.email))
  end

  protected

  def authorize_data_export
    authorize! :export, :data
  end

  def redirect_to_new_on_invalid_data
    #TODO: test this behaviour
    redirect_to :action => :new unless EXPORTS_TARGETS.include?(permitted_params[:data])
  end

  def set_selects_collections
    @targets = EXPORTS_LABELS.except(current_account.settings.finance.allowed? ? nil : :invoices).map(&:reverse)

    @periods = [['All', ''], ['Today', 'today'], ['This Week', 'this_week'],
                ['This Month', 'this_month'], ['This Year', 'this_year'],
                ['Previous Year', 'last_year']]
  end

  def permitted_params
    params.permit(:data, :period)
  end

end
