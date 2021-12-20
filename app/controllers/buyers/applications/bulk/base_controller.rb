# frozen_string_literal: true

class Buyers::Applications::Bulk::BaseController < Buyers::BulkBaseController
  before_action :find_applications

  protected

  def scope
    :applications
  end

  def find_applications
    @applications = collection.decorate
  end

  def collection
    current_account.provided_cinstances.where(id: selected_ids_param).includes(:user_account)
  end

  def errors_template
    'buyers/applications/bulk/shared/errors.html'
  end
end
