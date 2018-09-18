if ENV['DEBUG']
  module CallbackDebugging
    def make_lambda(filter)
      original_callback = super(filter)
      debug_callback(original_callback)
    end

    def debug_callback(callback)
      lambda do |target, *args, &block|
        begin
          result = callback.call(target, *args, &block)
        rescue => e
          result = false
        ensure
          debug_message(target, result)
          raise e if e
          result
        end
      end
    end

    def debug_message(target, result)
      return if chain_config[:terminator].blank?
      conditions = []

      conditions.push "if: #{Array.wrap(@if).join(' && ')}" if @if.present?
      conditions.push "unless: #{Array.wrap(@unless).join(' || ')}" if @unless.present?

      message = "#{target.class}[#{target.try(:id)}/#{target.object_id}](#{kind}_#{name}) #{conditions.join(',')} -> #{raw_filter}"
      Rails.logger.debug(wrap_debug_message(target, message, result))
    end

    def wrap_debug_message(target, message, result)
      if chain_config[:terminator].call(target, result)
        "!!! Callbacks halted: \e[0;31;49m#{message}\e[0m"
      else
        "Callbacks: \e[0;32;49m#{message}\e[0m"
      end
    end
  end

  ActiveSupport::Callbacks::Callback.prepend(CallbackDebugging)

  # ActiveSupport::Notifications.subscribe('halted_callback.action_controller') do |*args|
  #   filter = payload[:filter]
  #   message = filter.respond_to?(:debug_message) ? filter.debug_message : filter.to_s
  #   Rails.logger.debug { "!!> \033[1;31m#{message}\033[0m" }
  # end
end
