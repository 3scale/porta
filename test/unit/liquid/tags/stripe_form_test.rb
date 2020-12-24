require 'test_helper'

class StripeFormTest < ActiveSupport::TestCase
  def setup
    @context = Liquid::Context.new
    @context.registers[:controller] = ActionController::Base.new
    @stripe = Liquid::Tags::StripeForm.parse 'stripe_form', '', [], {}
  end

  def test_renders_with_stripe_elements
    @stripe.expects(:render_erb).with(@context, 'payment_gateways/stripe_elements', text: 'Edit Credit Card Details')
    @stripe.render(@context)
  end
end
