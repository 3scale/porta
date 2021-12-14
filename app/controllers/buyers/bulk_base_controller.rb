# frozen_string_literal: true

class Buyers::BulkBaseController < FrontendController
  before_action :authorize_bulk_operations

  protected

  def authorize_bulk_operations
    authorize! :manage, scope
  end

  def permitted_params
    params.premit(:selected)
  end

  def handle_errors
    render errors_template, status: :unprocessable_entity, formats: [:html] if @errors.present?
  end

  def errors_template
    raise NoMethodError
  end
end
