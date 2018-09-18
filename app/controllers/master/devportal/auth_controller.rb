class Master::Devportal::AuthController < ApplicationController

  include SiteAccountSupport

  skip_before_action :verify_authenticity_token

  before_action :show_error

  def show
    account = Account.find_by!(domain: params.require(:domain))

    redirect_to callback_url(account, domain: account.domain)
  end

  def show_self
    account = Account.find_by!(self_domain: params.require(:self_domain))

    redirect_to callback_url(account, domain: account.self_domain)
  end

  protected

  def callback_url(account, domain: )
    authentication_provider = account.authentication_providers.find_by!(system_name: params.require(:system_name))
    client = ThreeScale::OAuth2::Client.build(authentication_provider)

    base_url = if params[:invitation_token].present?
                 ThreeScale::Domain.callback_endpoint(request, account, domain)
               else
                 ThreeScale::Domain.current_endpoint(request, domain)
               end

    query_parameters = request.query_parameters.except(:domain).merge(master: true)

    client.callback_url(base_url, query_parameters)
  end

  AuthError = Struct.new(:message, :description, :uri)

  def show_error
    error = AuthError.new(*params.values_at(:error, :error_description, :error_uri))

    return unless error.message

    response.status = :unprocessable_entity
    render plain: [error.message, error.description, error.uri].compact.join("\n")
  end
end
