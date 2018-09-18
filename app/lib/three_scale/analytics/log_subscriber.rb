module ThreeScale
  module Analytics
    class LogSubscriber < ActiveSupport::LogSubscriber
      def fetch_info(event)
        return unless logger.debug?

        payload = event.payload

        debug "[Analytics] #{payload[:name]} (#{event.duration.round(1)}ms) #{payload[:info]}"
      end

      attach_to(:google_experiments)
    end
  end
end


