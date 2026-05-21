# frozen_string_literal: true

class Buyers::Applications::Bulk::BaseController < Buyers::BulkBaseController
  before_action :applications, only: :create

  helper_method :applications

  def create
    notify_success
  end

  protected

  def scope
    :applications
  end

  def applications
    @applications ||= collection.decorate
  end

  def collection
    @collection ||= current_account.provided_cinstances.where(id: selected_ids_param).includes(:service, user_account: [:admin_user])
  end

  def errors_template
    'buyers/applications/bulk/shared/errors'
  end
end
