require 'test_helper'

class StripeFormTest < ActiveSupport::TestCase
  def setup
    @context = Liquid::Context.new
    @context.registers[:controller] = ActionController::Base.new
    template = Liquid::Template.parse('{% stripe_form %}')
    @stripe = template.root.nodelist.first
    assert_instance_of Liquid::Tags::StripeForm, @stripe
  end

  def test_renders_with_stripe
    @stripe.expects(:render_erb).with(@context, 'payment_gateways/stripe', text: 'Edit Credit Card Details')
    @stripe.render(@context)
  end
end
