module ThreeScale
  class SidekiqLoggingMiddleware
    def call(worker_class, msg, *)
      yield
    ensure
      Rails.logger.info "Enqueued #{worker_class}##{msg['jid']} with args: #{msg['args']}"
    end
  end
end
