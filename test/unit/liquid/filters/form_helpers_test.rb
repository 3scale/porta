require 'test_helper'

class Liquid::Filters::FormHelpersTest < ActiveSupport::TestCase
  include Liquid
  include Liquid::Filters::FormHelpers

  attr_reader :errors

  def setup
    @context = Context.new
    @errors = ActiveModel::Errors.new(self)
  end

  test 'inline_errors' do
    model = Liquid::Drops::Model.new(self)

    assert_nil, inline_errors(model.errors)
    errors.add(:setup, 'set up')
    errors.add(:teardown, 'tore down')

    assert_equal '<p class="inline-errors">set up and tore down</p>', inline_errors(model.errors)
    assert_equal '<p class="inline-errors">set up</p>', inline_errors(model.errors.before_method(:setup))

    assert_equal '<p class="inline-errors">what an error</p>',
                 inline_errors(['what an error'])
    assert_equal '<p class="inline-errors">another one</p>',
                 inline_errors('another one')
  end

  test 'error_class' do
    assert_equal 'error', error_class(['what an error'])
    assert_equal 'error', error_class('another one')

    assert_equal '', error_class('')
    assert_equal '', error_class([])

    assert_equal 'error', error_class(['']) # FIXME: should not be error
  end
end
