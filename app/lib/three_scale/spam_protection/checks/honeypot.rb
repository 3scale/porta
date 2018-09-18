module ThreeScale::SpamProtection
  module Checks

    class Honeypot < Base
      attr_reader :attribute

      def initialize(config)
        super
        @attribute = config[:honeypot][:attribute] || :confirmation
      end

      def input(form)
        form.input attribute, :as => :boolean, :required => true,
                              :hint => "If you're human, leave this field empty.",
                              :wrapper_html => { :style => HIDE_STYLE }
      end

      def probability(object)
        case value = object.send(attribute)
        when "0"
          0
        else
          fail(value)
        end
      end

      def apply!(klass)
        attr = attribute
        klass.class_eval do
          attr_accessor attr
          spam_protection_attribute attr
        end
      end
    end

  end
end
