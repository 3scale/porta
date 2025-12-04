# frozen_string_literal: true

require 'test_helper'

class Liquid::ConditionCustomLiteralsTest < ActiveSupport::TestCase

  test "comparison with 'present' literal" do
    conditions = [
      '{% assign empty_array = "" | split: "," %}{% if empty_array != present %}OK{% endif %}-{% if present != empty_array %}OK{% endif %}',
      '{% assign non_empty_array = "one,two,three" | split: "," %}{% if non_empty_array == present %}OK{% endif %}-{% if present == non_empty_array %}OK{% endif %}',
      '{% assign empty_string = "" %}{% if empty_string != present %}OK{% endif %}-{% if present != empty_string %}OK{% endif %}',
      '{% assign non_empty_string = "whatever" %}{% if non_empty_string == present %}OK{% endif %}-{% if present == non_empty_string %}OK{% endif %}'
    ]

    conditions.each do |condition|
      template = Liquid::Template.parse(condition)
      assert_equal "OK-OK", template.render, "unexpected result for condition \"#{condition}\""
    end
  end

  test "comparison of drops with 'present' literal" do
    invoice = FactoryBot.build_stubbed(:invoice)
    invoice_drop = Liquid::Drops::Invoice.new(invoice)

    template = Liquid::Template.parse('{% if invoice == present %}OK{% endif %}-{% if present == invoice %}OK{% endif %}')
    assert_equal "OK-OK", template.render('invoice' => invoice_drop)

    template = Liquid::Template.parse('{% if invoice != present %}OK{% endif %}-{% if present != invoice %}OK{% endif %}')
    assert_equal "OK-OK", template.render('invoice' => nil)
  end
end
