# frozen_string_literal: true

class Buyers::BulkBaseController < FrontendController
  before_action :authorize_bulk_operations
  before_action :initializa_errors, only: :create

  def new; end

  def create
    @errors = nil

    recipients.each do |recipient|
      message = current_account.messages.build send_emails_params
      message.to = recipient

      @errors << message unless message.save && message.deliver!
    end

    handle_errors
  end

  protected

  def initializa_errors
    @errors = nil
  end

  def authorize_bulk_operations
    authorize! :manage, scope
  end

  def permitted_params
    params.permit(selected: [], send_emails: %i[subject body])
  end

  def send_emails_params
    permitted_params.fetch(:send_emails)
  end

  def handle_errors
    render errors_template, status: :unprocessable_entity, formats: [:html] if @errors.present?
  end

  def errors_template
    raise NoMethodError, "Please define `#errors_template` method in #{self.class}"
  end
end
