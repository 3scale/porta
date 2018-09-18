module Liquid
  module Tags

    class PaymentGatewayBaseForm < Liquid::Tags::Base

      def initialize(tag_name, text, tokens)
        @text= text.empty? ? "Edit Credit Card Details" : text[1..(text.strip.size-2)].strip
        super
      end
    end
  end
end
