# frozen_string_literal: true

class Provider::Admin::Account::AuthenticationProviderPublishingController < Provider::Admin::Account::BaseController
  before_action :authorize_rolling_update
  before_action :publishing_allowed?

  def create
    # using update_column cause we don't want to change updated_at when publishing
    # as that would render the oauth dance test out of date
    if authentication_provider.update_column(:published, true)
      flash[:success] = t('.success')
    else
      flash.now[:danger] = t('.error')
    end

    redirect_to provider_admin_account_authentication_provider_path(authentication_provider)
  end

  def destroy
    # using update_column cause we don't want to change updated_at when publishing as
    # that would render the oauth dance test out of date
    if authentication_provider.update_column(:published, false)
      flash[:success] = t('.success')
    else
      flash[:danger] = t('.error')
    end

    redirect_to provider_admin_account_authentication_provider_path(authentication_provider)
  end

  private

  def authentication_providers
    current_account.self_authentication_providers
  end

  def authentication_provider
    authentication_providers.find(params.require(:authentication_provider_id))
  end

  def authorize_rolling_update
    provider_can_use!(:provider_sso)
  end

  def authentication_provider_params
    params.require(:authentication_provider).permit(
      :published
    )
  end

  def publishing_allowed?
    publisher = AuthenticationProviderPublishValidator.new(current_account, authentication_provider)

    return if publisher.valid?

    redirect_to provider_admin_account_authentication_provider_url(authentication_provider), danger: publisher.error_message
  end
end
