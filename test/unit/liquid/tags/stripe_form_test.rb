# frozen_string_literal: true

require 'test_helper'

class StripeFormTest < ActiveSupport::TestCase
  def setup
    @context = Liquid::Context.new
    @context.registers[:controller] = ActionController::Base.new
    @stripe = Liquid::Tags::StripeForm.parse('stripe_form', '', '', Liquid::ParseContext.new)
  end

  def test_renders_with_stripe
    @stripe.expects(:render_erb).with(@context, 'payment_gateways/stripe', text: 'Edit Credit Card Details')
    @stripe.render(@context)
  end
end
