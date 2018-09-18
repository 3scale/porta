class Master::BaseController < ApplicationController
  before_action :force_master_domain

  private

  def authenticate_master!
    head(404) unless Account.master.users.include?(User.current)
  end

  def force_master_domain
    head(403) unless Account.is_master_domain?(request.host)
  end
end
