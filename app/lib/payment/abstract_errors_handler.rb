module Payment
  class AbstractErrorsHandler
    class NotFailedResultError < StandardError; end

    attr_reader :result
    alias response result

    # @param [Braintree::ErrorResult|ActiveMerchant::Billing::Response] result
    def initialize(result)
      raise NotFailedResultError, "cannot process successful result for #{result}" if result.success?
      @result = result
    end
  end
end
