# frozen_string_literal: true

module Liquid
  module Tags
    class StripeForm < Liquid::Tags::PaymentGatewayBaseForm
      desc 'Renders the stripe form'
      def render(context)
        controller = context.registers[:controller]
        stripe_publishable_key = controller.send(:site_account).payment_gateway_options[:publishable_key]
        intent = PaymentGateways::StripeCrypt.new(controller.send(:current_user)).create_stripe_setup_intent
        render_erb context, 'payment_gateways/stripe', text: @text, intent: intent, stripe_publishable_key: stripe_publishable_key
      end
    end
  end
end
