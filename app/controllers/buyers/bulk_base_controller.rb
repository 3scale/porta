# frozen_string_literal: true

class Buyers::BulkBaseController < FrontendController
  before_action :authorize_bulk_operations
  before_action :initialize_errors, only: :create

  def new; end

  def create
    raise NoMethodError, "Please define `#create` method in #{self.class}"
  end

  protected

  def initialize_errors
    @errors = []
  end

  def authorize_bulk_operations
    authorize! :manage, scope
  end

  def selected_ids_param
    params.require(:selected)
  end

  def handle_errors
    render errors_template, status: :unprocessable_entity, formats: [:html] if @errors.present?
  end

  def errors_template
    raise NoMethodError, "Please define `#errors_template` method in #{self.class}"
  end
end
