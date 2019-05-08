require 'test_helper'

class StripeFormTest < ActiveSupport::TestCase
  def setup
    @context = Liquid::Context.new
    @context.registers[:controller] = ActionController::Base.new
    @stripe = Liquid::Tags::StripeForm.parse 'stripe_form', '', [], {}
  end

  def test_renders_with_stripe_elements
    account = FactoryBot.build_stubbed(:provider_account)
    account.expects(:provider_can_use?).with(:stripe_elements).returns(true)
    @context.registers[:site_account] = account
    @stripe.expects(:render_erb).with(@context, 'payment_gateways/stripe_elements', text: 'Edit Credit Card Details')
    @stripe.render(@context)
  end

  def test_renders_with_stripe_v2
    account = FactoryBot.build_stubbed(:provider_account)
    account.expects(:provider_can_use?).with(:stripe_elements).returns(false)
    @context.registers[:site_account] = account
    @stripe.expects(:render_erb).with(@context, 'payment_gateways/stripe', text: 'Edit Credit Card Details')
    @stripe.render(@context)
  end
end