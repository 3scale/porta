# frozen_string_literal: true

require 'test_helper'

class StripeFormTest < ActiveSupport::TestCase
  test 'renders stripe with the right params' do
    context = Liquid::Context.new
    controller = DeveloperPortal::BaseController.new
    context.registers[:controller] = controller
    stripe = Liquid::Tags::StripeForm.parse 'stripe_form', '', [], {}

    setup_intent = Stripe::SetupIntent.new(id: 'seti_1I5s0l2eZvKYlo2CjumP89gc').tap { |si| si.update_attributes(client_secret: 'seti_1I6Fs82eZvKYlo2COrbF4OYY_secret_IhfCWxVPnPaXIYPlr9ORrd5noJDnDW7') }
    PaymentGateways::StripeCrypt.any_instance.expects(:create_stripe_setup_intent).returns(setup_intent)

    provider = FactoryBot.create(:simple_provider, payment_gateway_type: :stripe, payment_gateway_options: {login: 'sk_test_4eC39HqLyjWDarjtT1zdp7dc', publishable_key: 'pk_test_TYooMQauvdEDq54NiTphI7jx'})
    buyer = FactoryBot.create(:simple_buyer, provider_account: provider)
    user = FactoryBot.create(:admin, account: buyer)

    request = ActionDispatch::TestRequest.create
    request.host = provider.domain
    controller.stubs(request: request)
    controller.stubs(current_user: user)
    context.registers[:request] = request

    stripe.expects(:render_erb).with(context, 'payment_gateways/stripe', text: 'Edit Credit Card Details', intent: setup_intent, stripe_publishable_key: 'pk_test_TYooMQauvdEDq54NiTphI7jx')

    stripe.render(context)
  end
end
