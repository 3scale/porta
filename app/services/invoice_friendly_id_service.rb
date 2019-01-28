# frozen_string_literal: true

class InvoiceFriendlyIdService
  class CannotUpdateFriendlyIdException < StandardError
    def initialize(message, error)
      super(message)
      @error = error
    end

    attr_reader :error
  end

  class << self
    %i[call! call call_async].each do |method_sym|
      define_method(method_sym) do |*args|
        new(*args).public_send(method_sym)
      end
    end
  end

  def initialize(invoice)
    @invoice = invoice
  end

  attr_reader :invoice
  delegate :provider_account_id, :buyer_account_id, :friendly_id, to: :invoice

  def call!
    update_friendly_id
  rescue ActiveRecord::ActiveRecordError => exception
    tagged_exception = build_tagged_exception(exception, message: 'Cannot update invoice friendly_id.')
    report_and_ensure(tagged_exception) { raise tagged_exception }
  end

  def call
    update_friendly_id
  rescue ActiveRecord::ActiveRecordError => exception
    report_and_ensure(build_tagged_exception(exception, message: 'Cannot immediate update invoice friendly_id. Trying again async.')) { call_async }
    friendly_id
  end

  def call_async
    InvoiceFriendlyIdWorker.perform_async(invoice.id)
    friendly_id
  end

  protected

  def update_friendly_id
    return friendly_id if friendly_id.present? && friendly_id != default_friendly_id
    System::Database.execute_procedure 'sp_invoices_friendly_id', invoice.id
    invoice.reload.friendly_id
  end

  def default_friendly_id
    Invoice.column_defaults['friendly_id']
  end

  def build_tagged_exception(exception, options = {})
    CannotUpdateFriendlyIdException.new(options.fetch(:message, exception.message), exception)
  end

  def report_and_ensure(tagged_exception)
    report_error tagged_exception
  ensure
    yield
  end

  def report_error(tagged_exception)
    details = { invoice_id: invoice.id, provider_account_id: provider_account_id, buyer_account_id: buyer_account_id, error: tagged_exception.error }
    System::ErrorReporting.report_error(tagged_exception, details)
  end
end
