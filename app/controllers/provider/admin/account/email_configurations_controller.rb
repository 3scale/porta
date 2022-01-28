# frozen_string_literal: true

class Provider::Admin::Account::EmailConfigurationsController < Provider::Admin::Account::BaseController

  # We only enable it for master for now, feel free to roll it out for any provider
  before_action :ensure_master_domain, :email_configurations_enabled?

  activate_menu :account, :email_configurations

  helper_method :presenter

  def index; end

  def new
    @email_configuration = EmailConfiguration.new
  end

  def edit
    @email_configuration = account.email_configurations.find(params[:id])
  end

  def update
    @email_configuration = account.email_configurations.find(params[:id])

    if @email_configuration.update(configuration_params)
      redirect_to action: :index
      flash[:notice] = 'Email configuration updated'
    else
      render :edit
    end
  end

  def create
    @email_configuration = account.email_configurations.create(configuration_params)
    if @email_configuration.persisted?
      flash[:notice] = 'Email configuration created'
      redirect_to action: :index
    else
      render :new
    end
  end

  def destroy
    @email_configuration = account.email_configurations.find(params[:id])

    if @email_configuration.destroy
      redirect_to action: :index
    else
      redirect_to action: :edit
    end
  end

  protected

  alias account current_account

  def configuration_params
    # For the time being we only want to support user name and password override
    params.permit(email_configuration: %i[email user_name password]).fetch(:email_configuration)
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
