# frozen_string_literal: true

class Provider::Admin::Dashboard::Service::TopTrafficController < Provider::Admin::Dashboard::Service::BaseController
  respond_to :json

  layout false

  protected

  def widget_data
    { items: ::Dashboard::TopTrafficPresenter.new(stats_client, current_account.provided_cinstances).preload }
  end

  def stats_client
    ::Stats::Service.new(service)
  end
end
