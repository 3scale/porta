# Include this into controllers that implement searching via sphinx. This will handle
# search server connection errors gracefully.
module SearchSupport
  extend ActiveSupport::Concern

  included do
    rescue_from Riddle::ConnectionError, ThinkingSphinx::ConnectionError, with: :search_error
    rescue_from Riddle::ResponseError,   with: :search_error
  end

  private

    def search_error(exception)
      System::ErrorReporting.report_error exception,
        error_message: 'Sphinx is probably down', error_class: 'Search Error'
      Rails.logger.error "--> Sphinx search failed (but rescued)\n #{exception.backtrace.join("\n")}"
      render template: 'search/error', status: :service_unavailable
    end
end
