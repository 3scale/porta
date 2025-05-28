class Master::BaseController < ApplicationController
  before_action :force_master_domain

  include FlashAlerts

  private

  def authenticate_master!
    head(404) unless Account.master.users.include?(User.current)
  end

  def force_master_domain
    head(403) unless Account.is_master_domain?(request.internal_host)
  end
end
