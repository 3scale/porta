module Liquid
  module Tags

    class StripeForm < Liquid::Tags::PaymentGatewayBaseForm

      desc "Renders the stripe form"
      def render(context)
        account = context.registers[:site_account]
        template = account.provider_can_use?(:stripe_elements) ? 'payment_gateways/stripe_elements' : 'payment_gateways/stripe'
        render_erb context, template, text: @text
      end
    end
  end
end
