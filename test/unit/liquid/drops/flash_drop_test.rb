require 'test_helper'

class Liquid::Drops::FlashDropTest < ActiveSupport::TestCase
  include Liquid

  def setup
  end

  test 'no messages' do
    drop = Drops::Flash.new()
    assert_equal [], drop.messages
  end

  test 'with messages' do
    drop = Drops::Flash.new([[:notice, 'foo'], [:alert, 'bar']])
    assert drop.messages.all?{|x| x.is_a?(Liquid::Drops::Flash::Message)}
  end

  test 'message has a type' do
    drop = Drops::Flash.new([[:notice, 'lol']])
    assert_equal 'info', drop.messages[0].type
  end

  test 'message has a text' do
    drop = Drops::Flash.new([[:notice, 'foobar']])
    assert_equal 'foobar', drop.messages[0].text
  end
end
