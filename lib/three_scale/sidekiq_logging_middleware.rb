# frozen_string_literal: true

module ThreeScale
  class SidekiqLoggingMiddleware
    def call(worker_class, msg, *)
      yield
    ensure
      filtered_args = FilterArguments.new(msg['args']).filter
      Rails.logger.info "Enqueued #{worker_class}##{msg['jid']} with args: #{filtered_args.to_s.truncate(200)}"
    end
  end
end
