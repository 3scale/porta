# frozen_string_literal: true

class Provider::Admin::Account::EmailConfigurationsController < Provider::Admin::Account::BaseController
  # We only enable it for master for now, feel free to roll it out for any provider
  before_action :ensure_master_domain

  def index
  end

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
    else
      render :edit
    end
  end

  def create
    @email_configuration = account.email_configurations.create(configuration_params)
    if @email_configuration.persisted?
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

  def configuration_params
    params.permit(email_configuration: %i[email username password smtp_address_and_port])
  end
end