# frozen_string_literal: true

class Provider::Admin::Account::EmailConfigurationsController < Provider::Admin::Account::BaseController

  # We only enable it for master for now, feel free to roll it out for any provider
  before_action :ensure_master_domain, :email_configurations_enabled?
  before_action :find_email_configuration, only: %i[edit update destroy]

  activate_menu :account, :email_configurations

  helper_method :presenter

  def index; end

  def new
    @email_configuration = EmailConfiguration.new
  end

  def edit; end

  def update
    if @email_configuration.update(email_configuration_params)
      redirect_to({ action: :index }, success: t('.success'))
    else
      render :edit
    end
  end

  def create
    @email_configuration = email_configurations.create(email_configuration_params)
    if @email_configuration.persisted?
      redirect_to({ action: :index }, success: t('.success'))
    else
      render :new
    end
  end

  def destroy
    if @email_configuration.destroy
      redirect_to({ action: :index }, success: t('.success'))
    else
      redirect_to action: :edit
    end
  end

  protected

  delegate :email_configurations, to: :current_account

  def find_email_configuration
    @email_configuration = email_configurations.find(params[:id])
  end

  def email_configuration_params
    params.permit(email_configuration: %i[email user_name password]).require(:email_configuration)
  end

  def email_configurations_enabled?
    return if Features::EmailConfigurationConfig.enabled?

    render_error "Email Configurations are not enabled.", status: :not_found
  end

  def presenter
    @presenter ||= Provider::Admin::Account::EmailConfigurationsPresenter.new(provider: current_account,
                                                                              email_configuration: @email_configuration,
                                                                              params: params)
  end
end
