module ThreeScale
  class SidekiqLoggingMiddleware
    def call(worker_class, msg, *)
      yield
    ensure
      filtered_args = ThreeScale::FilterArguments.new(msg['args']).filter
      Rails.logger.info "Enqueued #{worker_class}##{msg['jid']} with args: #{filtered_args}"
    end
  end
end
