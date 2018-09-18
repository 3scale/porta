require 'test_helper'

class Apicast::LuaGeneratorTest < ActiveSupport::TestCase

  def self.generator
    name.sub(/Test$/, '').constantize
  end

  def setup
    skip "abstract generator can't be tested" if self.class.generator.abstract?

    @generator = self.class.generator.new
  end

  def test_filename
    assert @generator.filename
  end

  def test_emit
    assert @generator.emit(mock('provider'))
  end
end
