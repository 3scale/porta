require 'test_helper'

class Apicast::AbstractGeneratorTest < ActiveSupport::TestCase

  class SomeGenerator < AbstractGenerator
  end

  def setup
    @generator = SomeGenerator.new
  end

  def test_formats
    assert_equal [], @generator.formats
    @generator.formats = [:foo]
    assert_equal [:foo], @generator.formats
  end

  def test_assigns
    assert_equal Hash.new, @generator.assigns
  end

  def test_render_template
    assert_raise ActionView::MissingTemplate do
      @generator.render(template: 'template')
    end
  end

  def test_render_inline
    assert_equal 'foobar', @generator.render(inline: 'foobar')
  end

  def test_abstract
    assert Apicast::AbstractGenerator.abstract?
    refute @generator.class.abstract?
  end

  def test_lookup_context_prefixes
    assert_equal [Rails.root.join('app', 'lib', 'apicast').to_s], @generator.lookup_context.prefixes
  end
end
