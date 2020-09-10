# frozen_string_literal: true

class Master::Api::DomainController < Master::Api::BaseController
  respond_to :json

  include ApiAuthentication::ByAccessToken

  authenticate_access_token plain: 'unauthorized'
  self.access_token_scopes = :account_management

  def show
    respond_with(domain_info)
  end

  protected

  def domain
    ThreeScale::DomainSubstitution::Substitutor.to_internal(params.require(:id).to_s)
  end

  def domain_info
    System::DomainInfo.find(domain)
  end
end
