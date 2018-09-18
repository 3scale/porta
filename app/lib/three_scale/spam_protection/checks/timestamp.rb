module ThreeScale::SpamProtection
  module Checks

    class Timestamp < Base
      DEFAULT_SECRET_KEY = -> { Rails.application.key_generator.generate_key('spam-protection-checks-timestamp') }

      def initialize(config)
        super
        timestamp = config[:timestamp]
        @diff = timestamp[:diff] || 10.seconds
        # see CookieStore for more information
        @secret = timestamp[:secret] || secret || DEFAULT_SECRET_KEY
        #@digest = timestamp[:digest] || 'SHA1'
        #@verifier = ActiveSupport::MessageVerifier.new(key, @digest)
      end

      def encryptor
        @_encryptor ||= ActiveSupport::MessageEncryptor.new(key)
      end

      def input(form)
        form.input :timestamp, :as => :hidden, :value => encode(timestamp_value), :wrapper_html => { :style => HIDE_STYLE }
      end

      def probability(object)
        value = object.timestamp

        return fail(value) if value.blank?

        if value.respond_to?(:to_str) # string
          begin
            value = Time.zone.at(decode(value))
            diff_from_now(value)
          rescue TypeError, ArgumentError => error
            Rails.logger.error "[SpamProtection] malformed timestamp #{object.timestamp}. Error: #{error} Value: #{value}"
            fail(object.timestamp)
          end
        else
          diff_from_now(value)
        end
      end

      def diff_from_now(time)
        current = Time.zone.now
        diff = current - time
        # linear for now, but would be cool to do exponential growth
        # as in http://en.wikipedia.org/wiki/File:Exponential_pdf.svg
        Rails.logger.info "[SpamProtection] #{name} timestamp diff is #{diff} seconds"
        if diff > @diff
          0
        else
          1 - (diff.to_f / @diff)
        end
      end

      def encode(text)
        encryptor.encrypt_and_sign(text)
      end

      def decode(text)
        encryptor.decrypt_and_verify(text)
      rescue ActiveSupport::MessageEncryptor::InvalidMessage, ActiveSupport::MessageVerifier::InvalidSignature
        raise ArgumentError
      end

      def apply!(klass)
        klass.class_eval do
          spam_protection_attribute :timestamp

          def timestamp
            @spam_protection_timestamp
          end

          def timestamp=(val)
            @spam_protection_timestamp = val
            # check that it is string
          end
        end
      end

      private

      attr_reader :secret

      def timestamp_value
        Time.now.to_f
      end

      def key
        secret.respond_to?(:call) ? secret.call : secret
      end
    end

  end
end
