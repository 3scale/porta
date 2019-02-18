#frozen_string_literal: true

class Provider::Admin::CustomPoliciesController < Provider::Admin::BaseController
  before_action :find_service
  before_action :find_proxy

  activate_menu :account, :integrate, :policies

  layout 'provider'

  def index; end

  def edit; end

  protected

  def find_proxy
    @proxy = @service.proxy
  end

end
